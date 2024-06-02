def get_nested_value(obj, key):
  keys = key.split("/")
  current_obj = obj
  for key in keys:
    if key not in current_obj:
      return None
    current_obj = current_obj[key]
 
  return current_obj
 
# Test cases
object1 = {"a": {"b": {"c": "d"}}}
object2 = {"x": {"y": {"z": "a"}}}
 
test_cases = [
  (object1, "a/b/c", "d"),
  (object2, "x/y/z", "a"),
  (object1, "a/b/e", None),
  (object2, "w/z", None),
  (object1, "a/b", "d"), # Intentionally wrong test case to test the failure mechanism
]
 
for obj, key, expected_value in test_cases:
  result = get_nested_value(obj, key)
  try:
    assert result == expected_value
    print(f"Test passed for object: {obj}, key: {key}, expected value: {expected_value}, result: {result}")
  except AssertionError:
    print(f"Test failed for object: {obj}, key: {key}, expected value: {expected_value}, result: {result}")