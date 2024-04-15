import pandas as pd
from ydata_profiling import ProfileReport

def generate_eda_report(input_file, output_file):
    """
    Generate an Exploratory Data Analysis (EDA) report using pandas-profiling.

    Args:
    - input_file: Path to the input CSV file
    - output_file: Path to save the generated report (HTML)

    Returns:
    - None
    """
    # Read the CSV file into a pandas DataFrame
    df = pd.read_csv(input_file)

    # Generate the EDA report
    profile = ProfileReport(
                    df,
                    sort=None,
                    html={
                        "style": {"full_width": True}
                    }, 
                    correlations={
                        "auto": {"calculate": True},
                        "pearson": {"calculate": True},
                        "spearman": {"calculate": True},
                        "kendall": {"calculate": True},
                        "phi_k": {"calculate": True},
                        "cramers": {"calculate": True},
                    },
                    explorative=True,
                    title="Profiling Report"
                )

    # Save the report to an HTML file
    profile.to_file(output_file)


