CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_KILL_SESSION (vsSID NUMBER,
                                                       vsSerial NUMBER,
                                                       vsInst_ID NUMBER) AS
BEGIN
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''||vsSID||', '||vsSerial||', @'||vsInst_ID||''' IMMEDIATE';
END;

--

BEGIN
  NAGP_KILL_SESSION(5228,38311,2);
  END;
