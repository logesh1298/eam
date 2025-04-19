import 'package:eam/core/resources/data_state.dart';
import 'package:eam/core/usecase/usecase.dart';
import 'package:eam/features/2_workorder/domain/repositories/workorder_repository.dart';

import '../entities/workorder.dart';

class GetWorkOrderUsecase implements UseCase<DataState<List<WorkorderEntity>>, void> {
  final WorkOrderRepository _workOrderRepository;

  GetWorkOrderUsecase(this._workOrderRepository);

  @override
  Future<DataState<List<WorkorderEntity>>> call({void params}) {
    return _workOrderRepository.getWorkOrders();
  }


}


