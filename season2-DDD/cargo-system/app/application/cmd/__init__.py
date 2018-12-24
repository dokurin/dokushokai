import argparse
import textwrap

from . import cargo
from . import customer


def run() -> None:
    parser = argparse.ArgumentParser("貨物システムサンプルアプリ")

    parser.add_argument
    sub = parser.add_subparsers()
    _set_cargo_command(sub)
    _set_customer_command(sub)

    args = parser.parse_args()
    if hasattr(args, "func"):
        args.func(args)
    else:
        parser.print_help()
        parser.exit(1)


def _set_cargo_command(parser: argparse.ArgumentParser) -> None:
    cargo_ = cargo.Cargo()
    cargo_cmd = parser.add_parser("cargo", help="see `cargo -h`")
    cargo_sub = cargo_cmd.add_subparsers()
    add = cargo_sub.add_parser("add", help="sed `add -h`", usage=textwrap.dedent('''
        cargo add [-h] JSON_FILE_PATH

        JSON_FILE_PATH format:
            {
              "foo": "bar"
            }
    ''').strip())
    add.set_defaults(func=cargo_.add)
    add.add_argument(
        "input",
        metavar="JSON_FILE_PATH",
        help=textwrap.dedent("登録対象の貨物JSONファイルパス"),
    )

    find = cargo_sub.add_parser("find", help="sed `add -h`", usage="cargo add [-h] CARGO_ID")
    find.set_defaults(func=cargo_.find)
    find.add_argument(
        "cargo_id",
        metavar="CARGO_ID",
        help=textwrap.dedent("検索対象の貨物ID"),
    )


def _set_customer_command(parser: argparse.ArgumentParser) -> None:
    customer_ = customer.Customer()
    customer_cmd = parser.add_parser("customer", help="see `customer -h`")
    customer_sub = customer_cmd.add_subparsers()
    add = customer_sub.add_parser("add", help="sed `add -h`", usage=textwrap.dedent('''
        cargo add [-h] JSON_FILE_PATH

        JSON_FILE_PATH format:
            {
              "foo": "bar"
            }
    ''').strip())
    add.set_defaults(func=customer_.add)
    add.add_argument("input", metavar="JSON_FILE_PATH", help="登録対象の顧客JSONファイルパス")
