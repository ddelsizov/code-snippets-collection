#!/usr/bin/env python3

# My first python experience. 
# Very amateurish scriptlet, intended to parse and transform SNMP agent management IP Addressess stored in "bytea_hex" data type in MF NNMi's postgres db.
# It should result a single coulmn and row "table" caontaining <node name>[<snmp management address>] pairs.

import psycopg2
import sys
import codecs
import binascii
from io import StringIO
from tabulate import tabulate
from psycopg2.extras import NamedTupleCursor

# Get connection to Postges instance, create cursor and execute query:
def get_nodes():
    conn = psycopg2.connect(dbname="nnm", host="localhost", user="postgres", password="nnmP0stgr3S", cursor_factory=NamedTupleCursor)
    cursor = conn.cursor()
    cursor.execute("select nms_snmp_agent.name AS agent_name, nms_node.name AS node_name, nms_snmp_agent_settings.active_addr AS mgmt_addr from nms_snmp_agent JOIN nms_node on nms_snmp_agent.hosted_on=nms_node.id JOIN nms_snmp_agent_settings ON nms_snmp_agent.id=nms_snmp_agent_settings.id;")
    records_nodes = [row[0:3] for row in cursor.fetchall()]
    cursor.close()
    conn.close()

# Setup sys.stdout to go to stringIO library, before it is printed on later stages 

    old_stdout_nodes = sys.stdout
    new_stdout_nodes = StringIO()
    sys.stdout = new_stdout_nodes

# For each row resulted as result get node name and transform hex bytes into readable characters 
# "[1]" is node_name column resulted from the query.
# "[2] is mgmt_addr colum which stores the IP addressess as bytea type. We slice the resulted memory view between chars [24:33] as they contain meningful actual hex bytes. Eg. ac0d0003 = (172.13.0.3)
# Outputs are stored and "stringified" into new_stdout_nodes buffer before we print them

    for num, row in enumerate(records_nodes) :
     string_values = row[1]
     hex_values = bytes(row[2].hex()[24:33], encoding='utf8') 
     new_stdout_nodes.write(string_values) 
     print((list(binascii.unhexlify(hex_values)))) 

    output_nodes = new_stdout_nodes.getvalue() 
    sys.stdout = old_stdout_nodes

# Clean up the unhexed values by replacing , with . as separator and construct the mini table.
    Nodes = (output_nodes.replace(", ", ".")) 
    MainList = [[Nodes]]
    heads = ["Node_Name_Mgmt_Addr"]
    print(tabulate(MainList, headers=heads, tablefmt='fancy_grid', stralign='left'))
    return new_stdout_nodes, old_stdout_nodes, output_nodes, row

new_stdout_nodes, old_stdout_nodes, output_nodes, row_node = get_nodes()
