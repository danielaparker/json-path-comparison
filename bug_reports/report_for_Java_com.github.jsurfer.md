Results do not match other implementations

The following queries provide results that do not match those of other implementations of JSONPath
(compare https://github.com/cburgmer/json-path-comparison/tree/master/comparison):

- [ ] `$[-1:]`
  Input:
  ```
  ["first", "second", "third"]
  ```
  Expected output:
  ```
  ["third"]
  ```
  Actual output:
  ```
  ["first", "second", "third"]
  ```

- [ ] `$..key`
  Input:
  ```
  {"object": {"array": [{"key": "something"}, {"key": {"key": "russian dolls"}}], "key": "value"}, "key": "top"}
  ```
  Expected output:
  ```
  ["top", "value", "something", {"key": "russian dolls"}, "russian dolls"]
  ```
  Actual output:
  ```
  ["value", "something", "russian dolls", {"key": "russian dolls"}, "top"]
  ```


For reference, the output was generated by the program in https://github.com/cburgmer/json-path-comparison/tree/master/implementations/Java_com.github.jsurfer.