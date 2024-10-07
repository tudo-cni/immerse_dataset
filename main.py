#!/usr/bin/env python

"""
main.py: Test script for parsing and plotting measurement traces.

@author: Marcus Haferkamp, Simon Häger, Stefan Böcker, and Christian Wietfeld
@license: CC-BY-SA-4.0
@version: v0.1
@maintainer: Marcus Haferkamp, Simon Haeger
@email: {marcus.haferkamp, simon.haeger}@tu-dortmund.de
"""
import argparse
import time
from pathlib import Path

from matplotlib import pyplot as plt

def store_in_dict(modem: str,
                  mode: str,
                  metric: str,
                  trace_id: int,
                  rsrp_trace: list,
                  ) -> None:
    """
    Store trace data in dict.
    :param modem:
    :param mode:
    :param metric:
    :param trace_id:
    :param rsrp_trace:
    :return: None
    """
    global DATA_DICT

    # Check dict entries
    if DATA_DICT.get(modem, None) is None:
        DATA_DICT[modem] = {}
    if DATA_DICT[modem].get(mode, None) is None:
        DATA_DICT[modem][mode] = {}
    if DATA_DICT[modem][mode].get(metric, None) is None:
        DATA_DICT[modem][mode][metric] = {}

    DATA_DICT[modem][mode][metric][trace_id] = rsrp_trace


def plot_rsrp_trace(rsrp_data: list,
                    mode: str,
                    modem: str):
    """
    Plot rsrp trace.
    :return:
    """
    plt.plot(rsrp_data, label=f"{mode}@{modem}")
    plt.grid()
    plt.xlabel("Time (samples)")
    plt.ylabel("RSSI [dBm]")
    plt.legend()
    plt.tight_layout()
    plt.show()


def parse_csv(csv_path,
              target_modems=None,
              target_metrics=None,
              target_modes=None,
              target_tracks=None,
              show_plots=False,
              ):
    """
    Parse csv files for given path.
    :param csv_path:        Path to CSV files
    :param target_modems:   Filter for specific modems
    :param target_metrics:  Filter for specific channel metrics
    :param target_modes:    Filter for specific mode
    :param target_tracks:   Filter tracks
    :param show_plots:      Show RSRP plots
    :return:                Dict with parsed data
    """

    # Get CSV files
    csv_files = [f for f in csv_path.glob("**/*.csv") if f.is_file() and f.suffix == '.csv']

    # Optional: Filtering
    if isinstance(target_modems, list) and len(target_modems) > 0:
        csv_files = [f for f in csv_files if any([m in f.parts for m in target_modems])]
    if isinstance(target_metrics, list) and len(target_metrics) > 0:
        csv_files = [f for f in csv_files if any([m in f.name for m in target_metrics])]
    if isinstance(target_modes, list) and len(target_modes) > 0:
        csv_files = [f for f in csv_files if any([m in f.parts[1] for m in target_modes])]
    if isinstance(target_tracks, list) and len(target_tracks) > 0:
        csv_files = [f for f in csv_files if any([m in f.parts[1].split("_")[-1] for m in target_tracks])]
    # print(f"{[c for c in csv_files] = }")

    # Parse CSV to dict
    for csv_file in csv_files:
        mode = csv_file.parts[1]
        metric = csv_file.parts[-1].replace(".csv", "")
        modem = csv_file.parts[-2]
        trace_id = int(csv_file.parts[-3])

        with csv_file.open("rb") as f:
            rsrp = [float(x) for x in f.read().decode("utf-8").split(",")]

            # Save in dict
            store_in_dict(modem, mode, metric, trace_id, rsrp_trace=rsrp)

            # Plot trace
            if show_plots:
                plot_rsrp_trace(rsrp, mode=mode, modem=modem)

def parse_args():
    """
    Parse command line arguments.
    :return: parser instance
    """
    parser = argparse.ArgumentParser(
        prog='main.py',
        description='Parse and plot trace data',
        # epilog='Text at the bottom of help'
    )
    parser.add_argument('--modems', default=None, help='{"UE_A", "UE_B", "UE_C"}')
    parser.add_argument('--metrics', default=None, help='{"5G_drx_rsrp", "5G_prx_rsrp", "4G_prx_rsrp"}')
    parser.add_argument('--modes', default=None, help='{"agv", "pedestrian", "los"}')
    parser.add_argument('--tracks', default=None, help='{"track1", "track2"}')
    args = parser.parse_args()

    modems = args.modems.split(",") if args.modems is not None else None
    metrics = args.metrics.split(",") if args.metrics is not None else None
    modes = args.modes.split(",") if args.modes is not None else None
    tracks = args.tracks.split(",") if args.tracks is not None else None

    return modems, metrics, modes, tracks

# Path to CSVs
CSV_PATH = Path("csv")

# Optional: filter for modems
TARGET_MODEMS = None
# TARGET_MODEMS = ["UE_A", "UE_B", "UE_C"]

# Optional: filter for channel metric
TARGET_METRICS = None
# TARGET_METRICS = ["5G_drx_rsrp", "5G_prx_rsrp", "4G_prx_rsrp"]

# Optional: filter for mode
TARGET_MODES = None
# TARGET_MODES = ["agv", "pedestrian", "los"]

# Optional: filter tracks
TARGET_TRACKS = None
# TARGET_TRACKS = ["track1", "track2"]

DATA_DICT = dict()

if __name__ == '__main__':

    modems, metrics, modes, tracks = parse_args()

    start_time = time.time()

    # Parse csv data
    parse_csv(CSV_PATH,
              target_modems=modems,
              target_metrics=metrics,
              target_modes=modes,
              target_tracks=tracks,
              show_plots=False)

    print(f"Elapsed time: {time.time() - start_time:.2f}")

    # Plot trace from dict
    # plt.plot(DATA_DICT["UE_A"]["agv_track1"]["5G_drx_rsrp"][0])
    # plt.plot(DATA_DICT["UE_A"]["pedestrian_track1"]["5G_drx_rsrp"][0])
    # plt.show()
