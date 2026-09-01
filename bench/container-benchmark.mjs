import { Bench } from 'tinybench'
import { createRealisticFixture, SEED } from './create-realistic-fixture.mjs'
import {
  countContainerVisitsInFullTreeWalk,
  printLatencyChangeFromExpected,
} from './benchmark-utils.mjs'

const {
  parentIndexesByContainer,
  rootContainer,
  registrationNames
} = createRealisticFixture()
const containerVisits = countContainerVisitsInFullTreeWalk(parentIndexesByContainer)

console.log(
  `fixture: ${parentIndexesByContainer.length} containers, ` +
    `${containerVisits.toLocaleString('en-US')} container visits per full tree walk, ` +
    `${registrationNames.length.toLocaleString('en-US')} registrations (seed ${SEED})`
)

const bench = new Bench({
  name: 'container',
  time: 0,
  iterations: 50,
})

const sample = registrationNames.filter((_, index) => index % 25 === 0)
bench.add(`get ${sample.length} sampled registrations`, () => {
  sample.forEach((name) => rootContainer.get(name))
})

const EXPECTED_LATENCY_AVERAGE_MS = {
  'get 99 sampled registrations': 0.7,
}

await bench.run()
printLatencyChangeFromExpected(bench.tasks, EXPECTED_LATENCY_AVERAGE_MS)
