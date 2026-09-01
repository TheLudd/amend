import { createRequire } from 'node:module'
import { createSeededRandom, randomIntegerBetween } from './benchmark-utils.mjs'

const require = createRequire(import.meta.url)
require('coffee-script/register')
const Container = require('../lib/container')

export const SEED = 1337
export const GRAPH_SHAPE = {
  middleContainerCount: 55,
  // the first N middle containers form a chain (each has the previous one
  // as a parent) to give the graph depth
  chainedContainerCount: 12,
  // every middle container also picks this many random extra parents...
  extraParentsPerMiddleContainer: 5,
  // ...from the earliest 75% of the middle containers created before it,
  // which bounds the depth and the tree walk size
  extraParentPoolFraction: 0.75,
  registrationsInBase0: 30,
  registrationsInBase1: 200,
  registrationsPerMiddleContainer: 40,
  registrationsInRoot: 40,
}

// Containers in creation order: [base0, base1, ...middle containers, root].
// Each entry is the list of parent indexes of that container.
const buildParentIndexesByContainer = (random) => {
  const parentIndexesByContainer = [[], []] // the two bases have no parents
  const firstMiddleIndex = parentIndexesByContainer.length

  for (
    let middleIndex = 0;
    middleIndex < GRAPH_SHAPE.middleContainerCount;
    middleIndex += 1
  ) {
    const parentIndexes = new Set([0, 1]) // both bases, always
    const isInChain =
      middleIndex >= 1 && middleIndex < GRAPH_SHAPE.chainedContainerCount
    if (isInChain) parentIndexes.add(firstMiddleIndex + middleIndex - 1)
    if (middleIndex > 0) {
      const lastPoolIndex = Math.floor(
        (middleIndex - 1) * GRAPH_SHAPE.extraParentPoolFraction
      )
      for (
        let attempt = 0;
        attempt < GRAPH_SHAPE.extraParentsPerMiddleContainer;
        attempt += 1
      ) {
        parentIndexes.add(
          firstMiddleIndex + randomIntegerBetween(random, 0, lastPoolIndex)
        )
      }
    }
    parentIndexesByContainer.push([...parentIndexes])
  }

  const rootParentIndexes = [0, 1]
  for (let i = 0; i < GRAPH_SHAPE.middleContainerCount; i += 1) {
    rootParentIndexes.push(firstMiddleIndex + i)
  }
  parentIndexesByContainer.push(rootParentIndexes)
  return parentIndexesByContainer
}

const registrationCountForContainer = (containerIndex, containerCount) => {
  if (containerIndex === 0) return GRAPH_SHAPE.registrationsInBase0
  if (containerIndex === 1) return GRAPH_SHAPE.registrationsInBase1
  if (containerIndex === containerCount - 1) return GRAPH_SHAPE.registrationsInRoot
  return GRAPH_SHAPE.registrationsPerMiddleContainer
}

export const createRealisticFixture = () => {
  const random = createSeededRandom(SEED)
  const parentIndexesByContainer = buildParentIndexesByContainer(random)
  const containerCount = parentIndexesByContainer.length

  const containers = []
  const registrationNames = []
  parentIndexesByContainer.forEach((parentIndexes, containerIndex) => {
    const parents = parentIndexes.map((parentIndex) => containers[parentIndex])
    const container = new Container({}, parents)
    const registrationCount = registrationCountForContainer(
      containerIndex,
      containerCount
    )
    for (let valueIndex = 0; valueIndex < registrationCount; valueIndex += 1) {
      const registrationName = `container${containerIndex}Value${valueIndex}`
      container.value(registrationName, valueIndex)
      registrationNames.push(registrationName)
    }
    containers.push(container)
  })

  return {
    parentIndexesByContainer,
    rootContainer: containers[containers.length - 1],
    registrationNames,
  }
}
