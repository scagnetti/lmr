# This exceptions are thrown by data miners if none critical
# error occur and the algorithm can recover from this kind of errors
# and continue evaluating other data
class DataMiningError < RuntimeError
end