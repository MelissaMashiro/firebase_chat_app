import 'package:get/get.dart';

//El state es como el state que maejabamos en abastible arriba de todo
class ApplicationState {
  final _page = 0.obs;
  int get page => _page.value;
  set page(value)=> _page.value = value;
  
}
