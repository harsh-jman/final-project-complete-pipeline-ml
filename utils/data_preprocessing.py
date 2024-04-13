import os
import pandas as pd

def merge_and_export_data(directory_path, output_path):
    # Read data from CSV files
    approver_details_df = pd.read_csv(os.path.join(directory_path, 'APPROVERDETAILS.csv'))
    certificates_df = pd.read_csv(os.path.join(directory_path, 'CERTIFICATES.csv'))
    project_experiences_df = pd.read_csv(os.path.join(directory_path, 'PROJECTEXPERIENCES.csv'))
    skills_df = pd.read_csv(os.path.join(directory_path, 'SKILLS.csv'))
    users_df = pd.read_csv(os.path.join(directory_path, 'USERS.csv'))
    user_skills_df = pd.read_csv(os.path.join(directory_path, 'USERSKILLS.csv'))

    # Merge dataframes
    merged_df = pd.merge(user_skills_df, users_df, left_on='userId', right_on='_id', how='right')
    merged_df = pd.merge(merged_df, project_experiences_df, left_on='projectExperienceId', right_on='_id', how='left')
    merged_df = pd.merge(merged_df, certificates_df, left_on='certificateId', right_on='_id', how='left')
    merged_df = pd.merge(merged_df, approver_details_df, left_on='approverDetailId', right_on='_id', how='left')
    merged_df = pd.merge(merged_df, skills_df, left_on='skillId', right_on='_id', how='left')

    # Export merged data to CSV
    merged_df.to_csv(output_path, index=None)

# Example usage:
# Define the input directory path and output file path
# input_directory = 'staging_raw_data/'
# output_file_path = '../data/artifact/merged_Data.csv'  # Adjust the output file path as needed

# Call the function to merge and export the data
# merge_and_export_data(input_directory, output_file_path)


def preprocess_data(merged_df):
    fields = [
        'userId_x',
        'proficiency',
        'status_x',
        'hackerRankScore',
        'firstName',
        'lastName',
        'designation',
        'projectName',
        'description_x',
        'startDate',
        'endDate',
        'certificateName',
        'description_y',
        'issuingAuthority',
        # 'issueDate',
        'validityPeriodMonths',
        'approverUserId',
        'status_y',
        'comments',
        'rating',
        'skillName'
    ]

    merged_df = merged_df[fields]

    merged_df['startDate'] = pd.to_datetime(merged_df['startDate'])
    merged_df['endDate'] = pd.to_datetime(merged_df['endDate'])

    # Calculate total_project_days
    merged_df['total_project_days'] = (merged_df['endDate'] - merged_df['startDate']).dt.days

    merged_df.drop(['startDate', 'endDate'], axis=1, inplace=True)

    merged_df = merged_df.iloc[:, 1:]

    merged_df['chanceToApprove'] = merged_df.groupby('userId_x')['approverUserId'].transform('count')

    merged_df.drop(columns=['approverUserId'], inplace=True)

    merged_df['fullname'] = merged_df['firstName'] + ' ' + merged_df['lastName']

    # Drop both userId_x columns and the approverUserId column
    merged_df.drop(columns=['firstName', 'lastName'], inplace=True)

    manual_rename = {
        'status_x': 'VerificationStatus',
        'description_x': 'ProjectDescription',
        'description_y': 'CertificateDescription',
        'status_y': 'CurentStatus',
    }

    merged_df.rename(columns=manual_rename, inplace=True)

    # Fill NaN values with 0 for numeric columns and with an empty string for object columns
    for col in merged_df.columns:
        if merged_df[col].dtype == 'object':
            merged_df[col].fillna('', inplace=True)
        else:
            merged_df[col].fillna(0, inplace=True)

    # Assuming merged_df is your DataFrame
    # Identify rows where VerificationStatus is "Not Verified" and rating is greater than 0
    mask = (merged_df['VerificationStatus'] == 'Not Verified') & (merged_df['rating'] > 0)

    merged_df.loc[mask, 'rating'] *= -1

    # Define a custom mapping function
    def map_rating(value):
        if value == -5:
            return -1
        elif value == -4:
            return -3
        elif value == -2:
            return -2
        else:
            return value

    # Apply the custom mapping function to the rating column
    merged_df['rating'] = merged_df['rating'].map(map_rating)

    merged_df.to_csv('data/processed/eda.csv')

    columns_to_drop = ['VerificationStatus', 'designation', 'validityPeriodMonths', 'CurentStatus']
    merged_df.drop(columns=columns_to_drop, inplace=True)

    return merged_df

# Example usage:
# merged_df = pd.read_csv('../data/artifact/merged_Data.csv')
# processed_df = preprocess_data(merged_df)

