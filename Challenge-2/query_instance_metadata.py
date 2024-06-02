import boto3
 
# To access AWS, You can either set the AWS credentials in the environment variables or you can set them in the code itself.
def fetch_instance_details(instance_id, keys):
    session = boto3.Session()
    ec2_client = session.client('ec2')
    try:
        response = ec2_client.describe_instances(InstanceIds=[instance_id])
        # Fetching the first instance cause we are only specifying one instance ID
        instance = response['Reservations'][0]['Instances'][0]
        
        for key in keys:
            print(f"{key}: {instance[key]}")
    except Exception as e:
        print(f"Error retrieving instance information: {e}")
 
fetch_instance_details("i-0f46f8264e1d31323", ["InstanceId", "InstanceType", "PublicIpAddress", "State", "Tags"])