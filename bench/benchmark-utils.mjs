export const createSeededRandom = (seed) => {
  let state = seed >>> 0
  return () => {
    state = (state + 0x6d2b79f5) | 0
    let t = Math.imul(state ^ (state >>> 15), 1 | state)
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

export const randomIntegerBetween = (random, minInclusive, maxInclusive) =>
  minInclusive + Math.floor(random() * (maxInclusive - minInclusive + 1))

export const percentChange = (fromValue, toValue) =>
  ((toValue - fromValue) / fromValue) * 100

export const printLatencyChangeFromExpected = (
  tasks,
  expectedLatencyAverageMsByTaskName
) => {
  tasks.forEach((task) => {
    const expectedMs = expectedLatencyAverageMsByTaskName[task.name]
    if (expectedMs === undefined) {
      throw new Error(`No expected latency average for task "${task.name}"`)
    }
    const measuredMs = task.result.latency.mean
    const change = percentChange(expectedMs, measuredMs)
    const sign = change >= 0 ? '+' : ''
    console.log(
      `${task.name}: ${measuredMs.toFixed(1)} ms ` +
        `(expected ${expectedMs} ms, ${sign}${change.toFixed(1)}%)`
    )
  })
}

export const countContainerVisitsInFullTreeWalk = (parentIndexesByContainer) => {
  const visitsByContainer = []
  parentIndexesByContainer.forEach((parentIndexes, containerIndex) => {
    visitsByContainer[containerIndex] = parentIndexes.reduce(
      (visits, parentIndex) => visits + visitsByContainer[parentIndex],
      1
    )
  })
  return visitsByContainer[parentIndexesByContainer.length - 1]
}
