import BenchmarkSupport

@main extension BenchmarkRunner {}

@_dynamicReplacement(for: registerBenchmarks)
func benchmarks() {

    Benchmark("Ring") { benchmark in
        let state = State()
        await runner_continuations(benchmark: benchmark, state: state)
    }
}

// ==== ------------------------------------------------------------------------

struct State {
    let range: Int = 100_000
}

@MainActor
func ring(f: Task<Int, Never>) async -> Int {
    let val = await f.value
    return val + 1
}

@MainActor
func runner_continuations(benchmark: Benchmark, state: State) async {
    var innermostCC: CheckedContinuation<Int, Never>? = nil

    var previousTask: Task<Int, Never> = Task {
        await withCheckedContinuation { cc in
            innermostCC = cc
        }
    }

    for i in 0 ..< state.range {
        previousTask = Task {
            await previousTask.value + 1
        }
    }

    //START MEASURE
    benchmark.startMeasurement()

    innermostCC!.resume(returning: 1)
    let result: Int = await withCheckedContinuation { cc in }
}

//@MainActor
//func runner_tasks(benchState: State) async {
//    while (benchState -> KeepRunning()) {
//        benchState -> PauseTiming()
//
//        var futures: [Int] = []
//        let range = benchState.range // benchState.range(0)
//        futures.reserveCapacity(range)
//
//        let p: Task<Int, Error> // was promise
//        futures.push_back(ring(p.getFuture()))
//        for i in 0 ..< range {
//            futures.push_back(ring(futures.back()))
//        }
//
//        benchState -> ResumeTiming()
//
//        p.send(1)
//        let result: Int = await futures.last
//
//    }
//
//    benchState -> SetItemsProcessed(static_cast<long>(benchState -> iterations()) * benchState -> range(0))
//}
//
//func runner_tasks(benchmark: Benchmark, benchState: State) async {
////    while (benchState->KeepRunning()) {
////        benchState->PauseTiming()
//
//// ==== Setup
//    var futures: [Int] = []
//    let range = benchState.range // benchState.range(0)
//    futures.reserveCapacity(range)
//
//    let p: Task<Int, Error> // was promise
//    futures.push_back(ring(p.getFuture()))
//    for i in 0 ..< range {
//        futures.push_back(ring(futures.back()))
//    }
//
//    // ==== Benchmark start
//    // benchState->ResumeTiming()
//    benchmark.startMeasurement()
//
//    p.send(1)
//    let result: Int = await futures.last
////
////    }
////
////    benchState -> SetItemsProcessed(static_cast<long>(benchState -> iterations()) * benchState -> range(0))
//}
//
//func runner_group(benchmark: Benchmark, benchState: State) async {
//    await withTaskGroup(of: Int.self) { group in
//        var futures: [Int] = []
//        benchmark.startMeasurement()
//
//        for i in 0 ..< benchState.range {
//            async let value = await previous + 1
//            current = await value
//        }
//    }
//}
//
//
//func runner_asyncLet(benchmark: Benchmark, benchState: State) async {
//    var current = 0
//
//    async let previous = 1
//    for i in 0..<benchState.range {
//        async let value = await previous + 1
//        current = await value
//    }
//}
//
//// ====
////
////ACTOR static Future<int> ring(Future<int> f) {
////    int val = wait(f)
////    return val + 1
////}
////
////ACTOR static Future<Void> BM_RingActor(benchmark::State* benchState){
////
////    while (benchState->KeepRunning()) {
////        benchState->PauseTiming()
////
////        std::vector<Future<int>> futures
////        futures.reserve(benchState->range(0))
////
////        Promise<int> p
////        futures.push_back(ring(p.getFuture()))
////        for (int i = 1 i < benchState->range(0) ++i) {
////            futures.push_back(ring(futures.back()))
////        }
////
////        benchState->ResumeTiming()
////
////        p.send(1)
////        int result = wait(futures.back())
////
////    }
////
////    benchState->SetItemsProcessed(static_cast<long>(benchState->iterations()) * benchState->range(0))
////
////    return Void()
////}
////
////static void bench_ring_flow(benchmark::State& benchState) {
////    onMainThread([&benchState]() { return BM_RingActor(&benchState) }).blockUntilReady()
////}
////
////BENCHMARK(bench_ring_flow)->RangeMultiplier(2)->Range(8 << 2, 8 << 11)
