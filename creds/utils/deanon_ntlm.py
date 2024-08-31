import argparse

def parse_users(users):
    users_arr = []
    for user in users:
        split_user = user.split(":")
        username = f"{split_user[0]}:{split_user[1]}"
        hash_nt = split_user[3]
        hash_lm = split_user[2]

        obj = {
            "user": username,
            "hash_nt": hash_nt,
            "hash_lm": hash_lm
        }

        users_arr.append(obj)

    return users_arr

def parse_hashes(hashes):
    hashes_arr = []
    for h in hashes:
        split_hash = h.split(":")
        hash_nt = split_hash[0]
        hash_plaintext = split_hash[1]

        h_obj = {
            "hash_nt": hash_nt,
            "hash_plaintext": hash_plaintext
        }

        hashes_arr.append(h_obj)

    return hashes_arr

def parse_users_hashes(users, hashes):
    users_hashes = []

    for user in users:
        for hhash in hashes:
            if user["hash_nt"] != hhash["hash_nt"]:
                continue
            username = user["user"]
            hash_nt = user["hash_nt"]
            hash_nt_sanity = hhash["hash_nt"]
            hash_lm = user["hash_lm"]
            password = hhash["hash_plaintext"]
            
            users_hashes.append({
                "user": username,
                "hash_nt": hash_nt,
                "hash_nt_sanity": hash_nt_sanity,
                "hash_lm": hash_lm,
                "hash_plaintext": password
            })

    return users_hashes


def main():
    parser = argparse.ArgumentParser(
        prog="Deanon",
        description="Deanon broken hashes",
        epilog="Have fun ye"
    )

    parser.add_argument("users")
    parser.add_argument("hashes")
    parser.add_argument("output")

    args = parser.parse_args()

    users = []
    hashes = []

    with open(args.users, "r") as users_handle:
        users = users_handle.readlines()
        users = parse_users(users)

    with open(str(args.hashes), "r") as hashes_handle:
        hashes = hashes_handle.readlines()
        hashes = parse_hashes(hashes)

    user_hashes = parse_users_hashes(users, hashes)

    with open(str(args.output), "a+") as h_output:
        for user_hash in user_hashes:
            h_output.write(f"{user_hash['user']}:{str(user_hash['hash_lm'])}:{str(user_hash['hash_nt'])}:{user_hash['hash_plaintext']}")

if __name__ == "__main__":
    main()