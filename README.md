# IMMERSE DATASET

This repository contains raw sub-6 GHz and mmWave measurement data gathered for and evaluated in our paper **Machine Learning-aided Sensing in Private
mmWave Networks for Industrial Applications**. 

If you use this dataset, please cite our original work in [Citation](#citation).

## Measurement Setup
Our [paper](#citation) presents details about the indoor measurement setup used for gathering sub-6 GHz and mmWave traces
for LOS and passages of pedestrians and AGVs (automated guided vehicles) at different tracks.

## Dataset Structure
The dataset provides CSV-formated measurement files.  
```sh
    csv
     |- mode (los, user passages @ track)
      |- measurment ID
       |- modem (UE_A, UE_B, UE_C)
        |- channel metrics (prx, drx for sub-6 GHz (4G), mmWave (5G))    
 ```
For more information, see our [paper](https://cni.etit.tu-dortmund.de/newsdetail/machine-learning-aided-sensing-in-private-mmwave-networks-for-industrial-application-45414/).

## Acknowledgements
This work was funded by the German Federal Ministry of Education and Research
(BMBF) in the course of the *6GEM Research Hub* under the grant number 16KISK038.

## Quick start
We provide scripts for Python and Matlab, 
demonstrating how to parse and plot the provided measurement data.

### Python
Run the following commands to get started.

1. Clone this repository:
    ```sh
    git clone https://github.com/tudo-cni/immerse_dataset
    ```
2. Change into repo directory:
    ```
    cd immerse_dataset
    ```
   <details>
   <summary>Optional: Create virtual environment</summary>

   ```sh
    python venv venv
   ```
   Activate virtual environment ([more information](https://docs.python.org/3/tutorial/venv.html#creating-virtual-environments)).
   On **Unix** and **MacOS** run:
   ```sh
    source venv/bin/activate
   ```
   On **Windows** run:
   ```sh
    venv\Scripts\activate
   ```
   
   Install dependencies:
   ```sh
    pip install matplotlib
   ```

   </details>
3. Running `main.py -h` shows the help message with optional filtering parameters.
There is no filtering if no arguments are passed.
   ```sh
   python main.py -h
   
   usage: main.py [-h] [--modems MODEMS] [--metrics METRICS] [--modes MODES] [--tracks TRACKS]
   
   Parse and plot trace data
   
   optional arguments:
      -h, --help         show this help message and exit
      --modems MODEMS    {"UE_A", "UE_B", "UE_C"}
      --metrics METRICS  {"5G_drx_rsrp", "5G_prx_rsrp", "4G_prx_rsrp"}
      --modes MODES      {"agv", "pedestrian", "los"}
      --tracks TRACKS    {"track1", "track2"}
    ``` 
5. **Example:** Filter `5G_drx_rsrp` trace data of `UE_A` and `UE_B` for `agv` passages on `track1`:
   ```sh
   python main.py --modems UE_A,UE_B --metrics 5G_drx_rsrp --modems agv --tracks track1
   ```

### Matlab
If you use Matlab, simply navigate into the project dir and run 
the `main.m` script.  

## Citation
If you use this dataset or results in your paper, please cite our work ([author's version](https://cni.etit.tu-dortmund.de/newsdetail/machine-learning-aided-sensing-in-private-mmwave-networks-for-industrial-application-45414/)) as:
```
@InProceedings{haferkamp2024b,
	Author = {M. Haferkamp, S. H{\"a}ger, S. B{\"o}cker, and C. Wietfeld},
	Title = {Machine Learning-aided Sensing in Private {mmWave} Networks for Industrial Application},
	Booktitle = {IEEE Globecom Workshops (GC Wkshps)},
	Address = {Cape Town, South Africa},
	Month = dec,
	Year = {2024},
	Project = {6GEM},
}
```