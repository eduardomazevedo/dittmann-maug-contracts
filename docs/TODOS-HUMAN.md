# Dhiraj

1. clean description of their method. read SAS read paper. make sure it is correct. make sure it is fully specified (eg is variable coming from reference year or measurement year?).

2. Functions to write.
a. We always have main() that runs all analyses and produces all output. Reproducible research.
b. Need function get_contract_parameters(data). I am not sure whether this function should be for one executive year or for doing it for the whole dataset. Prob for one executive year makes more sense. I am not sure whether inputs should be the pandas dataframes that are needed (often only one row of each because of the reference year stuff). Or whether it is better to pass entire dataset along with desired year / CEO.
c. We should then use our function to try to reproduce their table 1. Produce some output in output/ with a comparison of table 1 and what we reproduced. If it works, make this an automated pytest. Eventually you will commit a csv with their table. And you can commit a yaml file of stats that they report in the paper, and that we try to match.