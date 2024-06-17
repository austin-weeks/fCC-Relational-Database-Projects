#!/bin/bash

psql="psql --tuples-only --username=freecodecamp --dbname=salon -c"

echo -e "\n---- Welcome to the Salon! ----\n"

main_menu () {
  if [[ -n $1 ]]; then
    echo -e $1
  fi
  echo -e "How can I help you?\n"
  services=$($psql "SELECT * FROM services")
  echo "$services" | while read service_id bar service_name; do
    echo -e "$service_id) $service_name"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    main_menu "Please input a number that corresponds to the desired service."
    return
  fi
  if [[ -z $($psql "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED") ]]; then
    main_menu "Please input a number that corresponds to the desired servce."
    return
  fi
  echo -e "\nGreat! Let's get you set up for an appointment."
  echo -e "What is your phone number?"
  read CUSTOMER_PHONE
  customer_name=$($psql "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $customer_name ]]; then
    echo -e "\nLooks like you're new here."
    echo "What is your name?"
    read CUSTOMER_NAME
    enter_customer_result=$($psql "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  formatted_name=$(echo $($psql "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'") | sed 's/ //g')
  echo -e "\nOkay $formatted_name, what time would you like to set for your appointment?"
  echo "ex: '11:39pm'"
  read SERVICE_TIME
  customer_id=$($psql "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  set_appointment_result=$($psql "INSERT INTO appointments (customer_id, service_id, time) VALUES ($customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ -z $set_appointment_result ]]; then
    main_menu "An error occurred while settings your appointment, please try again."
    return
  fi
  service_name_formatted=$(echo $($psql "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED") | sed -e 's/^ +| +$//')
  echo -e "\nI have put you down for a $service_name_formatted at $SERVICE_TIME, $formatted_name."

  echo "Would you like to make another appointment? [y/n]"
  read decision
  if [[ $decision == "y" || $decision == "Y" ]]; then
    main_menu ""
    return
  else
    echo -e "\nWe'll see you soon, thank you!\n"
  fi
}

main_menu