# Ironhack-Final_Project
# Churn Analysis in Subscription Services


### Dataset Details

Dataset Name: Telco Customer Churn

Description: This dataset provides information about customers from a telecom company, including customer demographics, account information, services subscribed (e.g., internet, phone), and whether they churned. It includes categorical and numerical features.

Features details:
- CustomerID: A unique ID that identifies each customer.
- Gender: The customer’s gender: Male, Female.
- Senior Citizen: Indicates if the customer is 65 or older: 1 if Yes, 0 if No.
- Partner: Indicates if the customer has a partner: Yes, No.
- Dependents: Indicates if the customer lives with any dependents: Yes, No. Dependents could be children, parents, grandparents, etc.
- Tenure: Indicates the total amount of months that the customer has been with the company by the end of the quarter specified above.
- Phone Service: Indicates if the customer subscribes to home phone service with the company: Yes, No.
- Multiple Lines: Indicates if the customer subscribes to multiple telephone lines with the company: Yes, No, No phone service.
- Internet Service: Indicates if the customer subscribes to Internet service with the company: No, DSL, Fiber Optic.
- Online Security: Indicates if the customer subscribes to an additional online security service provided by the company: Yes, No, No internet service.
- Online Backup: Indicates if the customer subscribes to an additional online backup service provided by the company: Yes, No, No internet service.
- Device Protection: Indicates if the customer subscribes to an additional device protection plan for their Internet equipment provided by the company: Yes, No, No internet service.
- Tech Support: Indicates if the customer subscribes to an additional technical support plan from the company with reduced wait times: Yes, No, No internet service.
- Streaming TV: Indicates if the customer uses their Internet service to stream television programing from a third party provider: Yes, No, No internet service. The company does not charge an additional fee for this service.
- Streaming Movies: Indicates if the customer uses their Internet service to stream movies from a third party provider: Yes, No, No internet service. The company does not charge an additional fee for this service.
- Contract: Indicates the customer’s current contract type: Month-to-Month, One Year, Two Year.
- Paperless Billing: Indicates if the customer has chosen paperless billing: Yes, No.
- Payment Method: Indicates how the customer pays their bill: Bank transfer (automatic), Credit card (automatic), Electronic check, Mailed check.
- Monthly Charge: Indicates the customer’s current total monthly charge for all their services from the company.
- Total Charges: Indicates the customer’s total charges, calculated to the end of the quarter specified above.

### Exploratory Data Analysis (EDA)

#### Interpretations:

Clients are more likely to churn if:
- They have no dependent and no partner
- They are a senior citizen (older than 65y)
- They are recent customers (less than 1 year)
- They have multiple lines (-> maybe because they will save more if they switch to a cheaper provider? could present specific offers for multiple lines)
- They have fiber optic Internet service
- They subscribe to Internet but do not subscribe to Online security, Online backup, Device protection, or Tech support services
- Their contract is month-to-month
- They pay via electronic check

### Hypothesis testing

#### Customers who have been using Telco’s services for over 1 year are less likely to churn
- Null Hypothesis (H₀): Customers who have been using Telco’s services for over one year are equally likely to churn as those who have been using it for less than or equal to one year.
- Alternative Hypothesis (H₁): Customers who have been using Telco’s services for over 1 year are less likely to churn.

```
Chi-Square Statistic: 708.78273968122
P-Value: 3.68007400698092e-156
```
We reject the null hypothesis. Customers who have been using Telco's services for over one year are less likely to churn.

#### Customers with month-to-month contracts are more likely to churn
- Null Hypothesis (H₀): Customers with month-to-month contracts are equally likely to churn as those with other types of contracts.
- Alternative Hypothesis (H₁): Customers with month-to-month contracts are more likely to churn.

```
Chi-Square Statistic: 1153.9716611093477
P-Value: 6.147585925549194e-253
```
We reject the null hypothesis. Customers with month-to-month contracts are more likely to churn.

#### Senior citizens are more likely to churn than non-senior citizens
- Null Hypothesis (H₀): Senior citizens are equally likely to churn as non-senior citizens.
- Alternative Hypothesis (H₁): Senior citizens are more likely to churn than non-senior citizens.

```
Z-Statistic: 12.663022223987696
P-Value: 9.477903507376036e-37
```
We reject the null hypothesis. Senior citizens are more likely to churn.

### Clustering Algorithms

#### Steps
##### 1. Transforming categorical features in numerical (dummification)
##### 2. Standardisation of numerical data
##### 3. Dimensionality reduction method
   - Testing relevancy of PCA method
> PCA may not be optimal as the first two components explain only  0.38 of the variance, which is less than 80%.
(show PCA 2D graph)

   - Testing relevancy of Isomap method
> Isomap method seems to be more relevant than PCA for the 2D projection as we discovered a 3rd cluster.
(show Isomap 2D graph)

##### 4. Clustering algorithm
    - Testing relevancy of K-means algorithm
> Testing visually with elbow method and scatter plot 
(show scatter plot and elbow method)

Testing with the average silhouette metric:
```
For n_clusters = 2 The average silhouette_score is : 0.6287866644619318
For n_clusters = 3 The average silhouette_score is : 0.6834975292525928
For n_clusters = 4 The average silhouette_score is : 0.5229949160215177
For n_clusters = 5 The average silhouette_score is : 0.509927850952412
For n_clusters = 6 The average silhouette_score is : 0.48045968416837737
```

We proved visually and with the average silhouette metric that we could analyse our dataset using 3 clusters.

      - Testing relevancy of HDBSCAN algorithm
Testing visually with a scatter plot
(show scatter plot)

HDBSCAN is not the optimal algorithm here as it did not identify the 3 clusters, which are however clearly defined on the graph.
We can indeed notice that the hdbscan labels are not accurate.

### Cluster Analysis

#### Interpretations:

- Cluster 0 : customers who usually have no dependent, who are subscribing to phone, DSL, and fiber optic services. Most of them have a month-to-month contract, paperless billing, and pay with electronic check. Our highest paying customers are part of this population, median monthly charge is around USD 80. They have a 33% chance of churn.
  
- Cluster 1 : customers subscribing to phone services but no internet service, usually having only one line, paying less than USD30 monthly mostly by mailed check, and mostly under 65 years old. These customers are unlikely to churn (less than 10%).

- Cluster 2 : customers subscribing to DSL internet services but no phone service, paying between 0 and USD80 per month, with the majority of customers paying between USD30 and USD50. They have about 25% chance of churn.

### General Insights & Business actions



### Tableau link (WIP)
https://public.tableau.com/app/profile/lucie.stenger/viz/Tableau_Telco_customers/SummaryDashboard?publish=yes
