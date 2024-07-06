
import pymysql
import pymysql.cursors

USERNAME = "Yash"
PASSWORD = "2809"

def input_data(prompt, typ=None, range=None):
    while True:
        try:
            ret = input(prompt + ": ")
            if typ:
                ret = typ(ret)
        except ValueError:
            print("Input type incorrect, please retry!")
            continue
        except KeyboardInterrupt:
            print()
            raise SystemExit

        if range is not None:
            if ret < range[0]:
                print(
                    f"Input must be greater than or equal to {range[0]}, please retry!"
                )
                continue

            if ret >= range[1]:
                print(f"Input must be lesser than {range[1]}, please retry!")
                continue

        return ret


def input_int(prompt, range=None):
    return input_data(prompt, int, range)


def input_float(prompt, range=None):
    return input_data(prompt, float, range)


def input_pincode(prompt):
    return input_int(prompt, (100000, 999999))


def cmd_exit():
    raise SystemExit


def input_choice(*args):
    new_args = []
    for arg in args:
        if not isinstance(arg, tuple):
            new_args.append((arg,))
        else:
            new_args.append(arg)

    new_args.append(("exit", cmd_exit))
    for i, s in enumerate(new_args, start=1):
        print(f"{i}. {s[0]}")

    print()
    ret = input_int("Enter your choice (as an integer)", (1, len(new_args) + 1)) - 1
    if len(new_args[ret]) == 2:
        new_args[ret][1]()

    return ret


def sql_run(cmd, args=(), many=False):
    try:
        if many:
            cur.executemany(cmd, args)
        else:
            cur.execute(cmd, args)
    except Exception as e:
        print("Database operation failed due to the following error")
        print(">>", e)
        con.rollback()


LOAN_TYPES = ("bank", "citizen", "hospital", "lea")


def cmd_insert():
    def new_citizen():
        sql_run(
            "INSERT INTO Citizen(name_first, name_last, dob, ad_doorno, ad_street, "
            "ad_pincode, income) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (
                input_data("Enter first name"),
                input_data("Enter last name"),
                input_data("Enter DOB (in 'YYYY-MM-DD' format)"),
                input_data("Enter door number (address line 1)"),
                input_data("Enter street name (address line 2)"),
                input_pincode("Enter area pincode (address line 3)"),
                input_float("Enter income"),
            ),
        )
        con.commit()
        cin = cur.lastrowid
        print(f"Created a new person with cin {cin}!")

    def new_patient():
        sql_run(
            "INSERT INTO Patients(nmpi, cin, treatment_cost) VALUES (%s, %s, %s)",
            (
                input_int("Enter nmpi"),
                input_int("Enter patient cin"),
                input_float("Enter treatment cost"),
            ),
        )
        patient_id = cur.lastrowid
        sql_run(
            "INSERT INTO Patients_diseases VALUES (%s, %s)",
            input_data(
                "Enter diseases (can be a comma separated list of strings)",
                lambda x: [(patient_id, i.strip()) for i in x.strip().split(",")],
            ),
            many=True,
        )
        sql_run(
            "INSERT INTO Patients_doctors VALUES (%s, %s)",
            input_data(
                "Enter doctor cin (can be a comma separated list of cin)",
                lambda x: [(patient_id, int(i.strip())) for i in x.strip().split(",")],
            ),
            many=True,
        )
        con.commit()
        print(f"Inserted a new patient with patient id {patient_id}!")

    def new_loan():
        print(f"Choose the entity that is receiving the loan")
        loan_entity = LOAN_TYPES[input_choice(*LOAN_TYPES)]
        sql_run(
            f"INSERT INTO R_loan_{loan_entity} VALUES (%s, %s, %s, %s, %s)",
            (
                input_int("Enter lender bank code"),
                input_int("Enter receiver entity id"),
                input_float("Enter loan amount"),
                input_float("Enter interest rate"),
                input_data("Enter repayment method"),
            ),
        )
        con.commit()

    def new_bank_account():
        sql_run(
            "INSERT INTO BankAccount(bank_code, cin, nominee, money_deposited) "
            "VALUES (%s, %s, %s, %s)",
            (
                input_int("Enter bank code"),
                input_int("Enter account owner cin"),
                input_int("Enter nominee cin"),
                input_float("Enter initial deposit amount"),
            ),
        )
        con.commit()
        bank_account_id = cur.lastrowid
        print(f"Created a new bank account with id {bank_account_id}!")

    def new_crime():
        sql_run(
            "INSERT INTO Crimes(lea, victim_cin, suspect_cin, neighbourhood) "
            "VALUES (%s, %s, %s, %s)",
            (
                input_int("Enter lea id"),
                input_int("Enter victim cin"),
                input_int("Enter suspect cin"),
                input_pincode("Enter neighbourhood pincode"),
            ),
        )
        fir_no = cur.lastrowid
        sql_run(
            "INSERT INTO Crimes_inspector VALUES (%s, %s)",
            input_data(
                "Enter inspector cin (can be a comma separated list of cin)",
                lambda x: [(int(i.strip()), fir_no) for i in x.strip().split(",")],
            ),
            many=True,
        )

        sql_run(
            "INSERT INTO Crimes_crimetype VALUES (%s, %s)",
            input_data(
                "Enter crime type (can be a comma separated list of strings)",
                lambda x: [(fir_no, i.strip()) for i in x.strip().split(",")],
            ),
            many=True,
        )

        sql_run(
            "INSERT INTO Crimes_charges VALUES (%s, %s)",
            input_data(
                "Enter crime charges (can be a comma separated list of strings)",
                lambda x: [(fir_no, i.strip()) for i in x.strip().split(",")],
            ),
            many=True,
        )
        con.commit()

        print(f"Recorded the crime with fir number {fir_no}!")

    input_choice(
        ("new citizen", new_citizen),
        ("new patient", new_patient),
        ("new loan", new_loan),
        ("create bank account", new_bank_account),
        ("record crime", new_crime),
    )


def cmd_update():
    def update_citizen_income():
        sql_run(
            "UPDATE Citizen SET income = %s WHERE cin = %s",
            (
                input_float("Enter updated income"),
                input_int("Enter citizen cin"),
            ),
        )
        con.commit()
        print(f"Updated citizen!")

    def update_neigbourhood_representative():
        sql_run(
            "UPDATE Neighbourhood SET representative = %s WHERE pincode = %s",
            (
                input_int("Enter new representative cin"),
                input_pincode("Enter area pincode"),
            ),
        )
        con.commit()
        print(f"Updated neighbourhood!")

    input_choice(
        ("update citizen income", update_citizen_income),
        ("update neighbourhood representative", update_neigbourhood_representative),
    )


def cmd_delete():
    def del_citizen():
        sql_run(
            "DELETE FROM Citizen WHERE cin = %s",
            (input_int("Enter cin"),),
        )
        con.commit()
        print(f"Deleted entry!")

    def del_patient():
        sql_run(
            "DELETE FROM Patients WHERE patient_id = %s",
            (input_int("Enter patient id"),),
        )
        con.commit()
        print(f"Deleted entry!")

    def del_loan():
        print(f"Choose the entity that is receiving the loan")
        loan_entity = LOAN_TYPES[input_choice(*LOAN_TYPES)]
        sql_run(
            f"DELETE FROM R_loan_{loan_entity} "
            f"WHERE bank_code = %s AND loan_{loan_entity} = %s",
            (
                input_int("Enter lender bank code"),
                input_int("Enter receiver entity id"),
            ),
        )
        con.commit()
        print(f"Deleted entry!")

    def del_bank_account():
        sql_run(
            "DELETE FROM BankAccount WHERE account_id = %s",
            (input_int("Enter account id"),),
        )
        con.commit()
        print(f"Deleted entry!")

    def del_crime():
        sql_run(
            "DELETE FROM Crimes WHERE fir_no = %s",
            (input_int("Enter fir no"),),
        )
        con.commit()
        print(f"Deleted entry!")

    input_choice(
        ("clear citizen", del_citizen),
        ("clear patient", del_patient),
        ("clear loan", del_loan),
        ("remove bank account", del_bank_account),
        ("resolve crime", del_crime),
    )


def cmd_selection():
    def select_people_below_income():
        sql_run(
            "SELECT cin, CONCAT(name_first, ' ', name_last) AS full_name, income "
            "FROM Citizen WHERE income < %s",
            (input_float("Enter income level to select people below it"),),
        )
        for row in cur:
            print(row)

    def select_law_enforcers():
        sql_run(
            "SELECT cin, CONCAT(name_first, ' ', name_last) AS full_name "
            "FROM Citizen WHERE cin in (SELECT employees FROM LEA_employees)"
        )
        for row in cur:
            print(row)

    input_choice(
        ("get people below an income", select_people_below_income),
        ("get law enforcers", select_law_enforcers),
    )


def cmd_projection():
    def project_diseases():
        sql_run("SELECT DISTINCT diseases FROM Patients_diseases")
        for row in cur:
            print(row["diseases"])

    def project_crimes():
        sql_run("SELECT DISTINCT charges FROM Crimes_charges")
        for row in cur:
            print(row["charges"])

    input_choice(
        ("get a projection of diseases", project_diseases),
        ("get a projection of crimes", project_crimes),
    )


def cmd_aggregate():
    def total_disease_victims():
        sql_run(
            "SELECT COUNT(*) AS ret FROM Patients_diseases WHERE Diseases = %s",
            (input_data("Enter disease name"),),
        )
        for row in cur:
            print(row["ret"])

    def average_tax_per_person():
        sql_run("SELECT AVG(income_tax) as ret FROM Citizen_tax")
        for row in cur:
            print(row["ret"])

    def highest_budget_lea():
        sql_run("SELECT * FROM LEA ORDER BY budget DESC LIMIT 1")
        for row in cur:
            print(row)

    input_choice(
        ("get number of victims of a disease", total_disease_victims),
        ("get average tax per person", average_tax_per_person),
        ("get LEA with highest budget", highest_budget_lea),
    )


def cmd_search():
    def search_apartment():
        sql_run(
            f"SELECT * FROM Citizen WHERE ad_doorno LIKE '%%{input_data('Enter apartment name')}%%'",
        )
        for row in cur:
            print(row)

    def search_neighbourhood_with_park():
        sql_run("SELECT * FROM Neighbourhood_landmark WHERE landmark LIKE '%%Park'")
        for row in cur:
            print(row)

    input_choice(
        ("get all citizens in an apartment by search", search_apartment),
        ("search for parks by neighbourhood", search_neighbourhood_with_park),
    )


def cmd_analysis():
    def crime_rate_by_neighbourhood():
        sql_run(
            "SELECT pincode, "
            "CONCAT(name_first, ' ', name_last) AS representative_name, "
            "COUNT(*) AS crime_count "
            "FROM Neighbourhood as N "
            "LEFT OUTER JOIN Citizen AS C ON N.representative = C.cin "
            "LEFT OUTER JOIN Crimes ON Crimes.neighbourhood = N.pincode "
            "GROUP BY pincode, representative_name "
            "ORDER BY crime_count DESC"
        )
        for row in cur:
            print(row)

    def hospitals_by_neighbourhood():
        sql_run(
            "SELECT S.pincode, "
            "CONCAT(name_first, ' ', name_last) AS representative_name, "
            "COUNT(*) AS hospital_count "
            "FROM Neighbourhood as N "
            "LEFT OUTER JOIN Citizen AS C ON N.representative = C.cin "
            "LEFT OUTER JOIN R_serves AS S on S.pincode = N.pincode "
            "GROUP BY pincode, representative_name "
            "ORDER BY hospital_count DESC"
        )
        for row in cur:
            print(row)

    input_choice(
        ("get crime rate by neighbourhood", crime_rate_by_neighbourhood),
        ("get hospital count by neighbourhood", hospitals_by_neighbourhood),
    )


try:
    con = pymysql.connect(
        host="localhost",
        user=USERNAME,
        password=PASSWORD,
        db="cityDBMS",
        cursorclass=pymysql.cursors.DictCursor,
    )
except Exception as e:
    print(e)
    print(
        "Connection Refused: Either username or password is incorrect "
        "or user doesn't have access to database"
    )
    raise SystemExit

if con.open:
    print("Connected")
else:
    print("Failed to connect")

with con.cursor() as cur:
    while True:
        print("\nChoose the next operation!")
        input_choice(
            ("insert", cmd_insert),
            ("update", cmd_update),
            ("delete", cmd_delete),
            ("selection", cmd_selection),
            ("projection", cmd_projection),
            ("aggregate", cmd_aggregate),
            ("search", cmd_search),
            ("analysis", cmd_analysis),
        )
