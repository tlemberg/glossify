from scraperutils import DBConnect

# Create an ArgumentParser
parser = argparse.ArgumentParser()
parser.add_argument("email")
parser.add_argument("permission")

# Parse the arguments
args = parser.parse_args()

# Connect to the DB
db = DBConnect()