import 'package:player/services/on_demand_api.dart';
import 'package:player/store/app_state.dart';
import 'package:redux_entity/redux_entity.dart';
import 'package:redux_epics/redux_epics.dart';

class OnDemandEpics extends EpicClass<AppState> {
  OnDemandEpics({required this.api});

  final OnDemandApiService api;

  Stream<dynamic> call(
      Stream<dynamic> actions, EpicStore<AppState> store) async* {
    await for (final action in actions) {
      if (action is RequestRetrieveAll<OnDemandProgram>) {
        final now = DateTime.now();
        if (store.state.onDemandPrograms.lastFetchAllTime == null ||
            now
                    .difference(store.state.onDemandPrograms.lastFetchAllTime!)
                    .inMinutes >
                30) {
          final shows = await api.getOnDemandPrograms();
          yield SuccessRetrieveAll<OnDemandProgram>(shows);
        } else {
          yield SuccessRetrieveAllFromCache<OnDemandProgram>(
              store.state.onDemandPrograms.entities.values.toList());
        }
      }
    }
  }
}
