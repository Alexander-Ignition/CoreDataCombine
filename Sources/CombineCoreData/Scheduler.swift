import Combine
import CoreData

extension NSManagedObjectContext: Scheduler {

    public typealias SchedulerTimeType = ImmediateScheduler.SchedulerTimeType
    public typealias SchedulerOptions = ImmediateScheduler.SchedulerOptions

    public var now: SchedulerTimeType {
        ImmediateScheduler.shared.now
    }

    public var minimumTolerance: SchedulerTimeType.Stride {
        ImmediateScheduler.shared.minimumTolerance
    }

    public func schedule(
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        perform(action)
    }

    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        perform(action)
        return AnyCancellable({ /* none */ })
    }

    public func schedule(
        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        perform(action)
    }
}
