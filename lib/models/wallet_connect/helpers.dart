/// Returns a dynamic session event params result
///
/// {
///  "success": true / false
///  "error": error message (when success is false)
///  "nonce": nonce (or ommitted)
///  "data": params (or ommitted when success is false)
/// }
///
dynamic getSessionEventParamsResult(
    {dynamic params, var nonce, String? error}) {
  var result = <dynamic, dynamic>{...params};
  if (nonce != null) {
    result["nonce"] = nonce;
  }
  if (error != null) {
    result["error"] = error;
    result["success"] = false;
  } else {
    result["success"] = true;
    result["data"] = params;
  }
  return result;
}
