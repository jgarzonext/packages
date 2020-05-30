--------------------------------------------------------
--  DDL for Package Body PAC_QUERY_TAB_ERROR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_QUERY_TAB_ERROR" IS
   FUNCTION f_row
      RETURN outrecset PIPELINED IS
      out_rec        outrec_type;
      lin_rec        outrecset;
      vmesact        VARCHAR2(6) := REPLACE(TO_CHAR(f_sysdate, 'YYYYMM'), ' ');
      vmesant        VARCHAR2(6) := REPLACE(TO_CHAR(ADD_MONTHS(f_sysdate, -1), 'YYYYMM'), ' ');
      vstatement_1   VARCHAR2(1000) := 'SELECT * from TAB_ERROR' || '_' || vmesact;
      vstatement_2   VARCHAR2(1000) := 'SELECT * from TAB_ERROR' || '_' || vmesant;
      vstatement     VARCHAR2(1000)
                         := 'SELECT 1 from TAB_ERROR' || '_' || vmesant || ' where rownum < 2';
      vhay_reg       NUMBER(1) := 0;
      no_existe_particion EXCEPTION;
      PRAGMA EXCEPTION_INIT(no_existe_particion, -00942);
   BEGIN
      BEGIN
         EXECUTE IMMEDIATE vstatement
                      INTO vhay_reg;
      EXCEPTION
         WHEN no_existe_particion OR NO_DATA_FOUND THEN
            vhay_reg := 0;
      END;

      IF NVL(vhay_reg, 0) = 0 THEN
         EXECUTE IMMEDIATE vstatement_1
         BULK COLLECT INTO lin_rec;
      ELSE
         vstatement := vstatement_1 || ' UNION ALL ' || vstatement_2;

         EXECUTE IMMEDIATE vstatement
         BULK COLLECT INTO lin_rec;
      END IF;

      FOR i IN lin_rec.FIRST .. lin_rec.LAST LOOP
         out_rec.ferror := lin_rec(i).ferror;
         out_rec.cusuari := lin_rec(i).cusuari;
         out_rec.tobjeto := lin_rec(i).tobjeto;
         out_rec.ntraza := lin_rec(i).ntraza;
         out_rec.tdescrip := lin_rec(i).tdescrip;
         out_rec.terror := lin_rec(i).terror;
         PIPE ROW(out_rec);
      END LOOP;

      RETURN;
   EXCEPTION
      WHEN no_data_needed THEN
         RETURN;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_query_tab_error.f_row', 1, SQLERRM, SQLCODE);
         RETURN;
   END f_row;
END pac_query_tab_error;

/

  GRANT EXECUTE ON "AXIS"."PAC_QUERY_TAB_ERROR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_QUERY_TAB_ERROR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_QUERY_TAB_ERROR" TO "PROGRAMADORESCSI";
