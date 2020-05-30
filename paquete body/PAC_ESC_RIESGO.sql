--------------------------------------------------------
--  DDL for Package Body PAC_ESC_RIESGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ESC_RIESGO" AS
   /******************************************************************************
      NOMBRE:      PAC_ESC_RIESGO
      PROP¿SITO:   Package Escala de Riesgo para las funciones de Escala de riesgo

      REVISIONES:
	    Ver        Fecha        Autor             Descripci¿n
	    ---------  ----------  ---------------  ------------------------------------
	    1.0        23/03/2017   ERH               1. Creaci¿n del package.

   ******************************************************************************/

   /******************************************************************************
     NOMBRE:     F_GRABAR_ESCALA_RIESGO
     PROP¿SITO:  Funci¿n que almacena los datos de la escala de riesgo.

     PARAMETROS:

          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error

   *****************************************************************************/
	FUNCTION f_grabar_escala_riesgo(
      pcescrie IN NUMBER,
       pndesde IN NUMBER,
	     pnhasta IN NUMBER,
      pindicad IN VARCHAR2,
      mensajes IN OUT T_IAX_MENSAJES )

      RETURN NUMBER is

      vobject    VARCHAR2(200) := 'pac_esc_riesgo.f_grabar_escala_riesgo';
      vpasexec   NUMBER(8) := 1;
      v_retorno  NUMBER(1) := 0;
      v_existe   NUMBER(1) := 0;
      vnumerr    NUMBER;
      salir      EXCEPTION;

       BEGIN

        SELECT count(*)
          INTO v_existe
          FROM ESCALARIESGO
         WHERE cescrie = pcescrie;


        IF v_existe = 0 THEN
          INSERT INTO ESCALARIESGO
                      (cescrie, ndesde, nhasta)
               VALUES (pcescrie, pndesde, pnhasta);

        END IF;


        IF v_existe = 1 AND (pindicad = 'E') THEN
         UPDATE ESCALARIESGO
            SET cescrie = pcescrie,
                 ndesde = pndesde,
                 nhasta = pnhasta
          WHERE  cescrie = pcescrie;
        END IF;

        IF v_existe = 1 AND (pindicad = 'N') THEN
          RAISE salir;
        END IF;


        --COMMIT;
        RETURN 0;
      EXCEPTION
        WHEN salir THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'No se puede guardar el registro, ya ha sido creada la escala de riesgo para el valor ingresado', SQLERRM);
         RETURN 1;
        WHEN OTHERS THEN
           RETURN 1;
      END f_grabar_escala_riesgo;


	/**********************************************************************
      FUNCTION F_GET_ESCALA_RIESGO
      Funci¿n que retorna los datos de la escala de riesgo
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_escala_riesgo
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_escala_riesgo.f_get_escala_riesgo';
      vparam         VARCHAR2(500) := 'par¿metros - : ';
      vpasexec       NUMBER := 1;

             sperrep  VARCHAR2(500);
          spersonAux  NUMBER(10,0);

       BEGIN
          OPEN v_cursor FOR

                SELECT e.cescrie, e.ndesde, e.nhasta, (SELECT d.TATRIBU
                                                         FROM DETVALORES d
                                                        WHERE d.CVALOR = 8001184
                                                          AND d.CIDIOMA = pac_md_common.f_get_cxtidioma
                                                          AND d.CATRIBU = e.cescrie)
                                                           AS TESCRIE
                  FROM escalariesgo e ORDER BY e.cescrie ASC;

          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_escala_riesgo;


    /**********************************************************************
      FUNCTION F_GET_SCORING_GENERAL
      Funci¿n que retorna los datos de scoring por persona.
      Param IN    psperson : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_scoring_general(
        psperson IN NUMBER
          )
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_escala_riesgo.f_get_scoring_general';
      vparam         VARCHAR2(500) := 'par¿metros - psperson: ' || psperson;
      vpasexec       NUMBER := 1;

             sperrep  VARCHAR2(500);
          spersonAux  NUMBER(10,0);

       BEGIN
          OPEN v_cursor FOR

               SELECT s.sperson, s.fcalcul, s.nfaccli, s.nfacjur, s.nfacpro,
                      s.nfaccal, s.nscotot
                 FROM score_general s
                WHERE s.sperson = psperson
                  AND ROWNUM <=5 ORDER BY s.fcalcul DESC;

          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_scoring_general;


END pac_esc_riesgo;

/

  GRANT EXECUTE ON "AXIS"."PAC_ESC_RIESGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ESC_RIESGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ESC_RIESGO" TO "PROGRAMADORESCSI";
