FOR EACH order NO-LOCK :
   FIND CURRENT order EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
   IF AVAILABLE order AND shipped = 'k'  THEN shipped = '' .
  IF AVAILABLE order THEN DISP order.cust-num shipped string(ROWID(order)) FORMAT 'x(21)'.
 
END.
