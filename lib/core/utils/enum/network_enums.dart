enum NetworkEnums {
  login('/users/signin'),
  forgotPassword('/api/users/forgotpassword'),
  workOrder('/workorder/getall'),
  favourite('/workorder/getwolistbyisfavourite'),
  dashboardWorkOrder('/workorder/search'),
  workOrderStatus('/selectlist/wostatus'),
  workOrderTask('/workordertask/getall/'),
  serviceRequest('/servicerequest/getall'),
  allLocation('/location/getall'),
  allName('/servicerequestname/getall'),
  allAssets('/assets/getall'),
  allparts('/inventory/getall'),
  assetById('/assets/getbyid/'),
  specifyById('/assettechspec/getbyassetid/'),
  assetPartsById('/assetparts/partsbyassetid/'),
  allProblems('/problems/getall/'),
  createServiceRequest("/servicerequest/create"),
  updateServiceRequest("/servicerequest/update"),
  createServiceDocument("/servicerequest/uploaddocument"),
  workType('/selectlist/workordertype'),
  workTypes('/worktype/getall'),
  failureClass('/failureclass/getall'),
  introOff('introOff'),
  workorderParts('/workorder/getcompletedetails/'),
  token('token');

  final String path;
  const NetworkEnums(this.path);
}
