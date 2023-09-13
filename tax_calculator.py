# Tested on Python Version 3.9
# Author: Christian Goeschel Ndjomouo
# Sep 13 2023
# Description: This Python program asks the user to enter his monthly salary before taxes obviously
#              and returns his monthly net salary and income tax.


# User input verification fucntion

def input_check():
    
    # User input stored in variable 'income'
    income = input("Please enter your monthly income before taxes: ")

    # Checking if the user input is a valid number
    if income.isnumeric():
        income = float(income)  # Storing the numeric value as a float
    else: 
        income = 0.0    # Store 0.0 as value which will trigger an error the tax_calc() fucntion

    return income 



def tax_calc(mon_income):

    tax_rate = 0

    # if statements for tax bracket determination

    if mon_income > 2500.0:     # If monthly income is higher than 2500 $
        tax_rate = 0.22
        print("Your monthly net income is:", str( mon_income - (mon_income * tax_rate) ) + "$" ,end="\n")
        print("You are paying",str(mon_income * tax_rate) + "$ per month.")

    elif mon_income <= 2500.0 and mon_income != 0.0:  # If monthly income is equal or less than 2500 $
        tax_rate = 0.18
        print("Your monthly net income is:",str( mon_income - (mon_income * tax_rate) ) + "$", end="\n")
        print("You are paying",str( mon_income * tax_rate ) + "$ per month.")
    else:
        print("Invalid input!")


tax_calc(input_check())










