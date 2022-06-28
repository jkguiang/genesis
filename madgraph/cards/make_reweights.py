import json
import argparse
import itertools

HEADER = """
change mode NLO       # Define type of Reweighting. For LO sample this command
                      # has no effect since only LO mode is allowed.
change helicity False # has also been done in the example I got from Kenneth
change rwgt_dir rwgt
"""

def make_reweights(config_json, output_file=""):
    """
    Writes reweight_card.dat (if an output file is given) based on a configuration 
    specified in a JSON file--example below. Outputs to stdout otherwise.

    Example config.json:
    {
        "coupling_group_1": [
            {
                "index": 1,
                "name": "coupling_1",
                "scan": [-2.0, -1.0, 0.0, 1.0, 2.0]
            },
            {
                "index": 2,
                "name": "coupling_2",
                "scan": [ ... ]
            },
            ...
        ],
        "coupling_group_2": [ ... ],
        ...
    }
    """

    with open(config_json, "r") as f_in:
        config = json.load(f_in)

    reweight_card = ""
    reweight_card += HEADER[1:] # trim leading \n

    identifiers = []
    points = []
    for coupling, coupling_scans in config.items():
        for scan_config in coupling_scans:
            index = scan_config["index"]
            name = scan_config["name"]
            identifiers.append((coupling, index, name))
            points.append(scan_config["scan"])

    point_combos = list(itertools.product(*points))
    for combo_i, point_combo in enumerate(point_combos):
        magic_comment = f"#[{combo_i+1}/{len(point_combos)}]"
        combo_name = "scan"
        set_lines = []
        for point_i, point in enumerate(point_combo):
            coupling, index, name = identifiers[point_i]
            set_lines.append(f"set {coupling} {index} {point} # {name}")
            combo_name += f"_{name}_{point}".replace("-", "m").replace(".", "p")
            magic_comment += f" {name}:{point}"

        reweight_card += f"\n{magic_comment}"
        reweight_card += f"\nlaunch --rewgt_name={combo_name}"
        reweight_card += ("\n" + "\n".join(set_lines) + "\n")
    
    if output_file:
        with open(output_file, "w") as f_out:
            f_out.write(reweight_card)
    else:
        print(reweight_card)

if __name__ == "__main__":
    cli = argparse.ArgumentParser(description="Write reweight_card.dat")
    cli.add_argument(
        "-c", "--config", type=str, required=True,
        help="Configuration JSON"
    )
    cli.add_argument(
        "-o", "--output", type=str,
        help="Output .dat file"
    )
    args = cli.parse_args()

    make_reweights(args.config, output_file=args.output)
