from flask import Flask
import pymysql
from flask import abort
from flask import request

app = Flask(__name__)
#flask --app notebooks/flask_app run --port 8080 --debug

@app.route("/carrier/<int:carrier_id>")
#http://localhost:8080/carrier/3
def carrier(carrier_id):
    db_conn = pymysql.connect(host="localhost", user="root", password="mysqlpassword", database="Telecoms_deals",
                              cursorclass=pymysql.cursors.DictCursor)
    if __name__ == "__main__":
        app.run(debug = True)
    
    with db_conn.cursor() as cursor:
        cursor.execute("""SELECT * FROM internet_plans WHERE Carrier_ID=%s""",(carrier_id, ))
        carrier = cursor.fetchone()
        if carrier is None:
            abort(404)

    db_conn.close() 
    return carrier

MAX_PAGE_SIZE = 100

@app.route("/Telco/cluster")
#http://localhost:8080/Telco/cluster?page=0&page_size=10&cluster=1&gdpr=1
def customer_cluster():
    page = int(request.args.get('page', 0))
    page_size = int(request.args.get('page_size', MAX_PAGE_SIZE))
    page_size = min(page_size, MAX_PAGE_SIZE)
    cluster = int(request.args.get('cluster', 0))
    gdpr = int(request.args.get('gdpr', 0))

    db_conn = pymysql.connect(host="localhost", user="root", password="mysqlpassword", database="Telecoms_deals",
                              cursorclass=pymysql.cursors.DictCursor)

    customers = []  
    last_page = None  

    if gdpr == 0:
        with db_conn.cursor() as cursor:
            cursor.execute("""SELECT Carrier_ID, Churn, Cluster, Contract, MonthlyCharges, MonthlyCharges_cat,
                                  DeviceProtection, InternetService, MultipleLines, OnlineBackup, OnlineSecurity,
                                  PaperlessBilling, PaymentMethod, TotalCharges, TotalCharges_cat, tenure,
                                  tenure_cat FROM telco_df_for_sql WHERE cluster=%s LIMIT %s OFFSET %s""", 
                               (cluster, page_size, page * page_size))
            customers = cursor.fetchall()

        # Fetch total count of customers in the specified cluster for pagination
        with db_conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS total FROM telco_df_for_sql WHERE cluster=%s", (cluster,))
            total_count = cursor.fetchone()['total']
            last_page = (total_count // page_size) + (1 if total_count % page_size > 0 else 0)

    elif gdpr == 1:
        with db_conn.cursor() as cursor:
            # Fetch customers for the specified cluster
            cursor.execute(
                    "SELECT * FROM telco_df_for_sql WHERE cluster=%s LIMIT %s OFFSET %s", 
                    (cluster, page_size, page * page_size)
                )
            customers = cursor.fetchall()

            # Fetch total count of customers in the specified cluster for pagination
        with db_conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS total FROM telco_df_for_sql WHERE cluster=%s", (cluster,))
            total_count = cursor.fetchone()['total']
            last_page = (total_count // page_size) + (1 if total_count % page_size > 0 else 0)

    db_conn.close()  # Ensure the database connection is closed

    return {
        'customers': customers,
        'next_page': f'/Telco/cluster?page={page + 1}&page_size={page_size}&cluster={cluster}',
        'last_page': last_page,
    }

if __name__ == "__main__":
    app.run(debug=True)