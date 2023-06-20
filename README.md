# IRTX JSprit to COPERT connector

## Introduction

This model is a connector between the upstream JSprit model and the downstream
COPERT model for emissions analysis.

The purpose of this connector is to process a given JSprit scenario and its
solution, aggregated the obtained vehicle traces to COPERT-compatible vehicle
type information and prepare the input file for COPERT.

## Requirements

### Software requirements

The converter is packaged in a Python script. All dependencies to run the model
have been collected in a `conda` environment, which is available in the LEAD
repository as `environment.yml`.

### Input / Output

#### Input

To run the model, a downstream JSprit scenario (`scenario.json`) and its JSprit
solution (`solution.json`) must be available.

#### Output

The output of the model is an Excel sheet that can be transmitted for emissions
calculation to the COPERT model (`copert.xlsx`).

#### Configuration

The conversion process needs to be configured using a configuration file (`configuration.json`)
in JSON format. It is structured as follows:

```json
{
  "peak_share": 0.3,
  "peak_speed_factor": 0.7,
  "temperature": {
    "min": [
      1.1, 1.4, 4.2, 7.2, 11.2, 15.0, 17.0, 16.6, 12.8, 9.6, 4.9, 2.0
    ],
    "max": [
      7.1, 9.0, 13.8, 17.4, 21.5, 25.6, 28.2, 28.0, 23.1, 17.7, 11.4, 7.7
    ]
  },
  "humidity": [
    84.0, 80.0, 74.0, 71.0, 72.0, 70.0, 65.0, 70.0, 76.0, 82.0, 84.0, 86.0
  ],
  "vehicle_type_mapping": {}
}
```

Since the JSprit model does not explicity take into account the time of day (but
the time elapsed from the first movements of a vehicle), the share of movements
during peak hour needs to be defined manually as `peak_share`. Furthermore, JSprit
solutions are based on optimal travel times. Therefore, the `peak_speed_factor`
can be defined to modulate the vehicle-specific speeds. After, maximum and
minimum temperatures for the twelve months of the year (starting January) are
given, as well as the mean humidity in percentage points. Finally, mappings from
the optimized JSprit vehicle types to the COPERT emission classes are given as
follows:

```json
{
  "vehicle_type_mapping": {
    "van": {
      "category": "Light Commercial Vehicles",
      "fuel": "Diesel",
      "segment": "N1-III",
      "euro_standard": "Euro 5",
      "fuel_tank_size": 100
    }
  }
}
```

Here, an example for the `van` JSprit vehicle type is given. It is mapped to a
light vehicle emissions class for Diesel with a specified fuel tank size.

## Running the model

The model is defined in a Jupyter notebook called `Convert.ipynb`. To run it,
call it through the `papermill` command line utility (which is installed as a
dependency in the `conda` environment) as described below:

```bash
papermill "Convert.ipynb" /dev/null \
  -pconfiguration_path /path/to/configuration.json \
  -pscenario_path /path/to/irtx-jsprit/scenario.json \
  -psolution_path /path/to/irtx-jsprit/solution.json \
  -poutput_path /path/to/output/copert.xlsx \
  -pyear 2022
```

The **mandatory** parameters are detailed in the following table:

Parameter             | Values                            | Description
---                   | ---                               | ---
`configuration_path`          | String                            | Path to the conversion configuration file (see above)
`scenario_path`          | String                            | Path to the JSprit scenario definition file
`solution_path`         | String                            | Path to the JSprit solution file
`output_path`         | String                            | Path where the COPERT data will be saved

The following **optional** parameter is available:

Parameter             | Values                            | Description
---                   | ---                               | ---
`year`     | Integer (default `2022`)                     | Year for which the information is written in the COPERT file

## Standard scenarios

For the Lyon living lab, a configuration file has already been prepared in
`data/configuration_lyon.json`. It can be used to prepare COPERT data for the
three main scenarios (Baseline 2022, UCC 2022, UCC 2030) as follows:

```bash
papermill "Convert.ipynb" /dev/null \
  -pconfiguration_path data/configuration_lyon.json \
  -pscenario_path /path/to/irtx-jsprit/output/scenario_{scenario}.json \
  -psolution_path /path/to/irtx-jsprit/output/solution_{scenario}.json \
  -poutput_path /path/to/irtx-jsprit-copert-connector/output/copert_{scenario}.xlsx \
  -pyear {year}
```

Here, `{scenario} = baseline_2022 | ucc_2022 | ucc_2030` and `year = 2022 | 2030`
according to the respective scenario.

### Examples

```
docker build -t jsprit-2-matsim-irtx:latest .
```

```
docker run --rm \
  -v ./sample-data:/data \
  jsprit-2-matsim-irtx:latest \
  /data/input/configuration.json \
  /data/input/scenario.json \
  /data/input/solution.json \
  2022 \
  /data/output
```
