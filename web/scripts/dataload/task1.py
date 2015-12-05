import argparse

import dbutils


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('--host', default='glossify.io',
		help='server name where the database lives')
	args = parser.parse_args()

	db = dbutils.DBConnect(args.host, 'tlemberg', 'tlemberg')

	print db


if __name__ == "__main__":
	main()