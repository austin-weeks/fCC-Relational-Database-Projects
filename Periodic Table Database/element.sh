#!/bin/bash

psql="psql --usernam=freecodecamp --dbname=periodic_table --no-align -t -c"
main () {
  if [[ -z $1 ]]; then
    echo Please provide an element as an argument.
    return
  fi

  #input is a number
  atomic_number=null
  if [[ $1 =~ ^[0-9]+$ ]]; then
    atomic_number=$($psql "SELECT atomic_number FROM elements WHERE atomic_number = $1")
  #input is a symbol
  elif [[ ${#1} -le 2 ]]; then
    atomic_number=$($psql "SELECT atomic_number FROM elements WHERE symbol = '$1'")
  #input is a name
  else
    atomic_number=$($psql "SELECT atomic_number FROM elements WHERE name ILIKE '$1'")
  fi

  #check if valid result
  if [[ -z $atomic_number ]]; then
    echo I could not find that element in the database.
    return
  fi

  #get element properties
  properties=$($psql "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number = $atomic_number")
  echo $properties | { IFS="|" read atomic_mass melting_point boiling_point type_id
    type=$($psql "SELECT type FROM types WHERE type_id = $type_id")
    element_info=$($psql "SELECT symbol, name FROM elements WHERE atomic_number = $atomic_number")
    echo $element_info | { IFS="|" read symbol name 
    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
    }
  }
}

main $1