# Because the subtask argument has fixed semantics (a percentage of the total),
# the environment can check the parts sum to 100. Percentages that don't add up
# are easy to introduce while editing subtasks and expensive to discover during
# a contest.
#
# This body sums to 90 on purpose. If the warning ever stops firing, the safety
# net is gone and nothing else would notice.

assert_compiles
assert_log_contains "Subtask percentages sum to 90, not 100"
