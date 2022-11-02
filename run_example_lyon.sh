set -e

## Prepare
cd /home/ubuntu/irtx-jsprit-copert-connector
mkdir /home/ubuntu/irtx-jsprit-copert-connector/output

## Create environment
conda env create -f environment.yml -n jsprit2copert

## Activate environment
conda activate jsprit2copert

## Run connector
papermill "Convert.ipynb" /dev/null \
  -pconfiguration_path data/configuration_lyon.json \
  -pscenario_path /home/ubuntu/irtx-jsprit/output/scenario_baseline_2022.json \
  -psolution_path /home/ubuntu/irtx-jsprit/output/solution_baseline_2022.json \
  -poutput_path /home/ubuntu/irtx-jsprit-copert-connector/output/copert_baseline_2022.xlsx \
  -pyear 2022

papermill "Convert.ipynb" /dev/null \
  -pconfiguration_path data/configuration_lyon.json \
  -pscenario_path /home/ubuntu/irtx-jsprit/output/scenario_ucc_2022.json \
  -psolution_path /home/ubuntu/irtx-jsprit/output/solution_ucc_2022.json \
  -poutput_path /home/ubuntu/irtx-jsprit-copert-connector/output/copert_ucc_2022.xlsx \
  -pyear 2022

papermill "Convert.ipynb" /dev/null \
  -pconfiguration_path data/configuration_lyon.json \
  -pscenario_path /home/ubuntu/irtx-jsprit/output/scenario_ucc_2030.json \
  -psolution_path /home/ubuntu/irtx-jsprit/output/solution_ucc_2030.json \
  -poutput_path /home/ubuntu/irtx-jsprit-copert-connector/output/copert_ucc_2030.xlsx \
  -pyear 2030
