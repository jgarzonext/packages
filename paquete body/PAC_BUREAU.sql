--------------------------------------------------------
--  DDL for Package Body PAC_BUREAU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_BUREAU" IS
  /******************************************************************************
     NOMBRE:     PAC_BUREAU
     PROP¿¿¿¿¿SITO:  Funciones Bureau


     REVISIONES:
     Ver        Fecha        Autor             Descripci¿¿¿¿n
     ---------  ----------  ---------------  ------------------------------------
     1.0        18/03/2013   LROA             1. Creaci¿¿¿¿n del package.
   ******************************************************************************/
e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   gempres        NUMBER := pac_md_common.f_get_cxtempresa;

  FUNCTION f_get_bureau(psseguro IN NUMBER)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2(200) := 'pac_bureau.f_get_bureau';
      terror         VARCHAR2(200);
      num_err        axis_literales.slitera%TYPE := 0;
      cur            sys_refcursor;
   BEGIN
      OPEN CUR FOR
        SELECT b.SFBUREAU, b.nmovimi, b.canulada,
		(SELECT UPPER(TRESPUE) FROM respuestas WHERE cpregun='2891' and CIDIOMA=pac_md_common.f_get_cxtidioma() and CRESPUE=b.CTIPO) CTIPO,
        b.iddoc_adj,PAC_AXISGEDOX.F_GET_FILEDOC(b.iddoc_adj) fichero,
        (select TMOTMOV FROM motmovseg m where m.cmotmov=b.nsuplem and CIDIOMA=pac_md_common.f_get_cxtidioma()) TSUPLEM ,
        b.nsuplem NSUPLEM,
        b.cusualt, b.falta,
        b.NMOVIMI,
        IDDOC_ADJ,
        pac_axisgedox.f_get_descdoc(IDDOC_ADJ) FICHERO_DESC ,
         SUBSTR(pac_axisgedox.f_get_filedoc(IDDOC_ADJ),
              INSTR(pac_axisgedox.f_get_filedoc(IDDOC_ADJ), '\', -1) + 1,
              LENGTH(pac_axisgedox.f_get_filedoc(IDDOC_ADJ)))  FICHERO
        FROM bureau b, seguros seg
        WHERE seg.SFBUREAU = b.SFBUREAU
        AND seg.sseguro = psseguro;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;


         RETURN cur;
  END f_get_bureau;


  FUNCTION f_anula_ficha(pfbureau IN NUMBER, pnsuplem IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
    vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - pfbureau = ' || pfbureau || 'pnsuplem = ' || pnsuplem|| 'pnmovimi = ' || pnmovimi;
      terror         VARCHAR2(200);
      VOBJECT        VARCHAR2(200) := 'PAC_BUREAU.f_anula_ficha';
      vanula NUMBER;
  BEGIN


  SELECT CANULADA
  INTO VANULA
  FROM BUREAU
  WHERE sfbureau = pfbureau
  and  NSUPLEM=pnsuplem
  and nmovimi=pnmovimi;

IF(VANULA = 0) THEN
    UPDATE bureau
    SET canulada = 1
    WHERE sfbureau = pfbureau
     and  NSUPLEM=pnsuplem
    and nmovimi=pnmovimi;


END IF;
IF(VANULA = 1) THEN
  UPDATE BUREAU
   SET CANULADA = 0
  WHERE sfbureau = pfbureau
     and  NSUPLEM=pnsuplem
     and nmovimi=pnmovimi;


END IF;


    RETURN 0;

 EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

  END f_anula_ficha;

  FUNCTION f_genera_ficha(psseguro IN NUMBER)
      RETURN NUMBER IS
       vpasexec       NUMBER(8) := 0;
       er       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - psseguro = ' || psseguro;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_BUREAU.f_genera_ficha';
      fbureau       bureau.SFBUREAU%TYPE;
      movimi        bureau.nmovimi%TYPE;
      suplem        BUREAU.NSUPLEM%TYPE;
      TIPO        BUREAU.CTIPO%TYPE;
      SUPLBUR BUREAU.NSUPLEM%TYPE;
      MOVSEG MOVSEGURO.NMOVIMI%TYPE;
  BEGIN

   BEGIN
   vpasexec:=1;
   SELECT max(SEG.SFBUREAU)
   into fbureau
        FROM bureau b, seguros seg        WHERE seg.SFBUREAU = b.SFBUREAU
        AND seg.sseguro = psseguro;
   vpasexec:=2;
    IF fbureau is NULL THEN
       fbureau := SEQ_BUREAU.NEXTVAL;
       movimi := 1;
    ELSE
      Select (MAX(NMOVIMI)+1)
      into movimi
      from bureau where sfbureau = fbureau;
    END IF;
     vpasexec:=3;
    EXCEPTION WHEN NO_DATA_FOUND THEN
  vpasexec:=4;
    fbureau := SEQ_BUREAU.NEXTVAL;

    movimi := 1;
   END;
    VPASEXEC:=5;
    SELECT MOV.CMOTMOV, MOV.NMOVIMI
    into suplem, MOVSEG
    FROM MOVSEGURO MOV WHERE SSEGURO=PSSEGURO
	  AND ROWNUM = 1
    order by nmovimi desc
	;

     vpasexec:=6;

    IF movimi>1 THEN
    VPASEXEC:=7;

    SELECT DISTINCT NSUPLEM
    INTO  SUPLBUR
    FROM BUREAU WHERE SFBUREAU = FBUREAU
	AND NMOVIMI = MOVIMI-1;

    ER:= F_ANULA_FICHA(FBUREAU,SUPLBUR , MOVIMI-1);

    END IF;

    vpasexec:=8;
   BEGIN

    select CRESPUE
    INTO tipo
    FROM PREGUNPOLSEG WHERE CPREGUN=2891 AND SSEGURO=PSSEGURO
    and nmovimi = MOVSEG;

  vpasexec:=9;
    EXCEPTION WHEN NO_DATA_FOUND THEN

    tipo:=null;
   END;
 vpasexec:=10;
    INSERT INTO bureau (SFBUREAU, NMOVIMI, NSUPLEM,CUSUALT,FALTA,CTIPO,canulada) VALUES (fbureau,movimi,SUPLEM, f_user, f_sysdate,tipo,0);

 vpasexec:=11;

    Update seguros set sfbureau= fbureau   where sseguro=psseguro;

    vpasexec:=12;


    RETURN 0;

     EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);


  END F_GENERA_FICHA;

-- DESC BUREAU
  FUNCTION f_valida_pol(psseguro IN NUMBER)
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - psseguro = ' || psseguro;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_BUREAU.f_valida_pol';
      situac        seguros.CSITUAC%TYPE;
	   tburo       NUMBER(8) := 0;
  BEGIN
    SELECT CSITUAC
     into situac
        FROM seguros
        WHERE sseguro = psseguro;

    BEGIN

    select count(CRESPUE)
    into tburo
    from pregunpolseg
    where cpregun='2891'
    and sseguro=psseguro;


    EXCEPTION WHEN NO_DATA_FOUND THEN

    tburo:=0;
   END;

    IF(situac in(4,5,0) and tburo>0) THEN

    RETURN 0;
    ELSE
    RETURN 1;
    END IF;
  END f_valida_pol;


  FUNCTION f_asocia_doc(psseguro IN NUMBER, pnsuplemen IN NUMBER, pnmovimi IN NUMBER ,  piddoc IN NUMBER)
      RETURN NUMBER IS
  vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - pfbureau = ' || psseguro || 'pnsuplemen = ' || pnsuplemen || 'piddoc = ' || piddoc|| 'pnmovimi = ' || pnmovimi;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_BUREAU.f_asocia_doc';
  BEGIN

 UPDATE bureau
   SET iddoc_adj = piddoc
 WHERE sfbureau = psseguro
   AND NSUPLEM = PNSUPLEMEN
   and nmovimi=pnmovimi;
   COMMIT;
   RETURN 0;
END f_asocia_doc;


END PAC_BUREAU;

/

  GRANT EXECUTE ON "AXIS"."PAC_BUREAU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_BUREAU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_BUREAU" TO "PROGRAMADORESCSI";
