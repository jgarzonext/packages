--------------------------------------------------------
--  DDL for Package Body PAC_UNDERWRITING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_UNDERWRITING" AS
   /******************************************************************************
      NOMBRE:      pac_underwriting
      PROPÃ“SITO:   Package propio para la validaciÃ³n dinÃ¡mica de acciones y funciones
                   de validaciÃ³n existentes en la tabla PDS_SUPL_AUTOMATIC y
                   PDS_SUPL_ACCIONES (Suplementos automÃ¡ticos y diferidos)


      REVISIONES:
      Ver        Fecha        Autor             DescripciÃ³n
      ---------  ----------  ---------------  ------------------------------------
       1.0       13/03/2015  RSC               1. Creación del package
       1.1       29/07/2015  IGIL              2. Creacion de las funciones encargadas
                                                  de insertar , editar y eliminar citas medicas
       1.2       27/08/2015  IGIL              3. se quita weigth y heigth de f_get_casedata
       2.0       15/10/2015  JCP               4. Se modifica la funcion f_get_risk_lifeinfo(
   ******************************************************************************/

   /***********************************************************************
        param in psseguro        : Identificador de seguro.
        return                   : Number (0--> Ok, codigo --> error).
     ***********************************************************************/
   FUNCTION f_get_caseproperties(psseguro IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN XMLTYPE IS
      v_caseproperties XMLTYPE;
      v_crespue_1954 NUMBER;
      v_crespue_1955 NUMBER;
      v_res          NUMBER;
      v_trespue_1954 respuestas.trespue%TYPE;
      v_trespue_1955 respuestas.trespue%TYPE;
   BEGIN
      v_res := pac_preguntas.f_get_pregunpolseg(psseguro, 1954, ptablas, v_crespue_1954);

      IF v_res <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_caseproperties', 1,
                     'psseguro=' || psseguro || ' ptablas = ' || ptablas || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
      END IF;

      SELECT trespue
        INTO v_trespue_1954
        FROM respuestas
       WHERE cpregun = 1954
         AND crespue = v_crespue_1954
         AND cidioma = pac_md_common.f_get_cxtidioma;

      v_res := pac_preguntas.f_get_pregunpolseg(psseguro, 1955, ptablas, v_crespue_1955);

      IF v_res <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_caseproperties', 2,
                     'psseguro=' || psseguro || ' ptablas = ' || ptablas || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
      END IF;

      SELECT trespue
        INTO v_trespue_1955
        FROM respuestas
       WHERE cpregun = 1955
         AND crespue = v_crespue_1955
         AND cidioma = pac_md_common.f_get_cxtidioma;

      SELECT XMLELEMENT("caseProperties",
                        XMLCONCAT(XMLELEMENT("property", xmlattributes('URErbName' AS "name"),
                                             v_trespue_1954),
                                  XMLELEMENT("property", xmlattributes('URElocale' AS "name"),
                                             'en')))
        INTO v_caseproperties
        FROM DUAL;

      RETURN v_caseproperties;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('**** SQLERRM = ' || SQLERRM);
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_casePropertiesp', 1,
                     'psseguro=' || psseguro || ' ptablas = ' || ptablas, SQLERRM);
         RETURN NULL;
   END f_get_caseproperties;

   /***********************************************************************
        Función que actualiza la nrenova

        param in psseguro        : Identificador de seguro.
        return                   : Number (0--> Ok, codigo --> error).
     ***********************************************************************/
   FUNCTION f_get_casedata(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN XMLTYPE IS
      v_caseproperties1 XMLTYPE;
      v_caseproperties2 XMLTYPE;
      v_caseproperties XMLTYPE;
      v_entitytype   VARCHAR2(50) := 'life';
      v_entityname   VARCHAR2(50) := '1';
      v_crespue_1901 pregunpolseg.crespue%TYPE;
      v_res          NUMBER;
      v_contaaseg    NUMBER;
      v_channel      XMLTYPE;
      v_bovtrustee      XMLTYPE;
      v_inspurpose      XMLTYPE;
      v_interviewtype   XMLTYPE;
      v_endowment       XMLTYPE;
      v_risk_types      XMLTYPE;
      v_disability      XMLTYPE;
   BEGIN
      v_bovtrustee := pac_underwriting.f_get_attributebovtrustee(psseguro, pfefecto, pnmovimi, ptablas);
      v_inspurpose := pac_underwriting.f_get_attributeinspurpose(psseguro, pfefecto, pnmovimi, ptablas);
      v_interviewtype := pac_underwriting.f_get_attributeinterviewtype(psseguro, pnriesgo, pfefecto, pnmovimi, ptablas, v_entityname);
      v_channel := pac_underwriting.f_get_attributechannel(psseguro, pnmovimi, ptablas);
      v_endowment := pac_underwriting.f_get_attributeendowment(psseguro, ptablas);
      v_risk_types := pac_underwriting.f_get_attributerisk_types(pcempres, psseguro, pnriesgo, pnmovimi, ptablas);
      v_disability := pac_underwriting.f_get_disability_present(pcempres, psseguro, pnriesgo, pnmovimi, ptablas);

      SELECT
                        XMLELEMENT("entity",
                                   xmlattributes(v_entitytype AS "type",
                                                 v_entityname AS "name"),
                                   XMLCONCAT(pac_underwriting.f_get_attributename(psseguro, pnriesgo, ptablas),
                                             pac_underwriting.f_get_attributegender(psseguro, pnriesgo, ptablas),
                                             pac_underwriting.f_get_attributesmoker(pcempres, psseguro,
                                                                   pnriesgo, ptablas),
                                             pac_underwriting.f_get_attributesmoker_last2(pcempres, psseguro,
                                                                         pnriesgo, ptablas),
                                             pac_underwriting.f_get_attributeage(psseguro, pnriesgo, pfefecto,
                                                                pnmovimi, ptablas),
                                             pac_underwriting.f_get_attributecountry(psseguro, pnriesgo,
                                                                            ptablas, v_entityname),
                                             pac_underwriting.f_get_attributebmi(psseguro, pnriesgo, pfefecto,
                                                                pnmovimi, ptablas),
                                             v_risk_types,
                                             pac_underwriting.f_get_attributeage_band(psseguro, pnriesgo, pfefecto,
                                                                pnmovimi, ptablas),
                                             pac_underwriting.f_get_attributesum_insured(psseguro, pnriesgo, pfefecto, pnmovimi, ptablas),
                                             v_disability,
                                             v_bovtrustee,
                                             v_inspurpose,
                                             v_interviewtype,
                                             v_channel,
                                             v_endowment,
                                             pac_underwriting.f_get_risk_based_values(pcempres, psseguro,
                                                                     pnriesgo, pnmovimi,
                                                                     ptablas)))
        INTO v_caseproperties1
        FROM DUAL;

      IF ptablas = 'EST' THEN
         SELECT COUNT(1)
           INTO v_contaaseg
           FROM estassegurats
          WHERE sseguro = psseguro
            AND ffecmue IS NULL
            AND(ffecfin IS NULL
                OR ffecfin > pfefecto);
      ELSE
         SELECT COUNT(1)
           INTO v_contaaseg
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecmue IS NULL
            AND(ffecfin IS NULL
                OR ffecfin > pfefecto);
      END IF;

      -- Life 2
      IF v_contaaseg = 2 THEN
         v_entityname := v_contaaseg;

         SELECT XMLELEMENT("entity",
                                      xmlattributes(v_entitytype AS "type",
                                                    v_entityname AS "name"),
                                      XMLCONCAT(pac_underwriting.f_get_attributename(psseguro, pnriesgo,
                                                                    ptablas, v_entityname),
                                                pac_underwriting.f_get_attributegender(psseguro, pnriesgo,
                                                                      ptablas, v_entityname),
                                                pac_underwriting.f_get_attributesmoker(pcempres, psseguro,
                                                                      pnriesgo, ptablas,
                                                                      v_entityname),
                                                pac_underwriting.f_get_attributesmoker_last2(pcempres, psseguro,
                                                                            pnriesgo, ptablas,
                                                                            v_entityname),
                                                pac_underwriting.f_get_attributeage(psseguro, pnriesgo,
                                                                   pfefecto, pnmovimi, ptablas,
                                                                   v_entityname),
                                                pac_underwriting.f_get_attributecountry(psseguro,
                                                                               pnriesgo,
                                                                               ptablas,
                                                                               v_entityname),
                                                pac_underwriting.f_get_attributebmi(psseguro, pnriesgo,
                                                                   pfefecto, pnmovimi, ptablas,
                                                                   v_entityname),
                                                v_risk_types,
                                                pac_underwriting.f_get_attributeage_band(psseguro, pnriesgo, pfefecto,
                                                                pnmovimi, ptablas, v_entityname),
                                                pac_underwriting.f_get_attributesum_insured(psseguro, pnriesgo, pfefecto, pnmovimi, ptablas),                                                v_disability,
                                                v_bovtrustee,
                                                v_inspurpose,
                                                v_interviewtype,
                                                v_channel,
                                                v_endowment,
                                                pac_underwriting.f_get_risk_based_values(pcempres, psseguro,
                                                                        pnriesgo, pnmovimi,
                                                                        ptablas, v_entityname)))
           INTO v_caseproperties2
           FROM DUAL;
      END IF;

      SELECT XMLELEMENT("caseData", XMLCONCAT(v_caseproperties1, v_caseproperties2))
        INTO v_caseproperties
        FROM DUAL;

      RETURN v_caseproperties;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('**** SQLERRM = ' || SQLERRM);
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_casedata', 1,
                     'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                     || ' ptablas = ' || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_casedata;

   FUNCTION f_get_attributename(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_sperson      NUMBER;
      v_nombre       VARCHAR2(200);
      v_attribute    XMLTYPE;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT sperson
           INTO v_sperson
           FROM estassegurats
          WHERE sseguro = psseguro
            AND norden = plife;

         v_nombre := f_nombre_est(v_sperson, 3);
      ELSE
         SELECT sperson
           INTO v_sperson
           FROM asegurados
          WHERE sseguro = psseguro
            AND norden = plife;

         v_nombre := f_nombre(v_sperson, 3);
      END IF;

      SELECT XMLELEMENT("attribute", xmlattributes('NAME' AS "name", v_nombre AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('**** 1 SQLERRM = ' || SQLERRM);
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributename', 1,
                     'psseguro=' || psseguro || ' ptablas = ' || ptablas || ' plife = '
                     || plife,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributename;

   FUNCTION f_get_attributegender(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_sperson      NUMBER;
      v_csexper      NUMBER;
      v_nombre       VARCHAR2(200);
      v_attribute    XMLTYPE;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT sperson
           INTO v_sperson
           FROM estassegurats
          WHERE sseguro = psseguro
            AND norden = plife;

         SELECT csexper
           INTO v_csexper
           FROM estper_personas
          WHERE sperson = v_sperson;
      ELSE
         SELECT sperson
           INTO v_sperson
           FROM asegurados
          WHERE sseguro = psseguro
            AND norden = plife;

         SELECT csexper
           INTO v_csexper
           FROM per_personas
          WHERE sperson = v_sperson;
      END IF;

      SELECT XMLELEMENT("attribute", xmlattributes('GENDER' AS "name", v_csexper AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('**** 2 SQLERRM = ' || SQLERRM);
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributegender', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas || ' plife = ' || plife,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributegender;

   FUNCTION f_get_attributeheight(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_crespue_7    pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
   BEGIN
      IF plife = 1 THEN
         v_res := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, 7, ptablas, v_crespue_7);
      ELSIF plife = 2 THEN
         v_res := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, 77, ptablas, v_crespue_7);
      END IF;

      IF v_res <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributeheight', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
      END IF;

      SELECT XMLELEMENT("attribute", xmlattributes('HEIGHT' AS "name", v_crespue_7 AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributeheight', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributeheight;

   FUNCTION f_get_attributeweight(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_crespue_8    pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
   BEGIN
      IF plife = 1 THEN
         v_res := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, 8, ptablas, v_crespue_8);
      ELSIF plife = 2 THEN
         v_res := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, 88, ptablas, v_crespue_8);
      END IF;

      IF v_res <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributeweight', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
      END IF;

      SELECT XMLELEMENT("attribute", xmlattributes('WEIGHT' AS "name", v_crespue_8 AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributeweight', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributeweight;

   FUNCTION f_get_attributeage(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_edad         pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
   BEGIN
      -- Revisar que esté bien esta función.
      v_edad := pac_albsgt_generico.f_edad_aseg(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi,
                                           NULL, NULL, NULL, NULL, plife);

      SELECT XMLELEMENT("attribute", xmlattributes('AGE' AS "name", v_edad AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributeage', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributeage;

      FUNCTION f_convert_db_num_fmt(v_num VARCHAR2)
         RETURN VARCHAR2 IS
         p_num          VARCHAR2(512) := v_num;
         p_decsep       VARCHAR2(1);
      BEGIN
         -- ,. significa que la coma es los decimales y el punto los miles.
         -- ., significa que el punto es los decimales y la coma los miles (EN)
         --
         SELECT SUBSTR(VALUE, 1, 1) VALUE
           INTO p_decsep
           FROM nls_session_parameters
          WHERE parameter = 'NLS_NUMERIC_CHARACTERS';

         -- Dejar separador en decimales si el separador de decimales
         -- es coma.
         --
         IF (p_decsep = ',') THEN
            p_num := REPLACE(p_num, ',', '*');
            p_num := REPLACE(p_num, '.', '');   -- Reemplazar separador de miles (.) si se encuentra
         END IF;

         -- Dejar separador en decimales solamente si el separador de decimales
         -- es punto.
         --
         IF (p_decsep = '.') THEN
            p_num := REPLACE(p_num, '.', '*');
            p_num := REPLACE(p_num, ',', '');   -- Reemplazar separador de miles (.) si se encuentra
         END IF;

         p_num := REPLACE(p_num, '*', p_decsep);   -- Dejar número solo con el formato decimal
         RETURN p_num;
      END f_convert_db_num_fmt;

   FUNCTION f_get_attributebmi(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_imc          pregunseg.crespue%TYPE;
      v_imcdef       VARCHAR2(50);
      v_res          NUMBER;
      v_attribute    XMLTYPE;
   BEGIN
      -- Revisar que esté bien esta función.
      IF plife = 1 THEN
         v_imc := pac_albsgt_generico.f_imc(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi, NULL,
                                       NULL, NULL, NULL);
      ELSIF plife = 2 THEN
         v_imc := pac_albsgt_generico.f_imc2(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi, NULL,
                                             NULL, NULL, NULL);
      END IF;
      v_imcdef := REPLACE(TO_CHAR(v_imc), ',', '.'); -- f_convert_db_num_fmt(v_imc);

      SELECT XMLELEMENT("attribute", xmlattributes('BMI' AS "name", v_imcdef AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributebmi', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributebmi;

   FUNCTION f_get_attributecountry(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_sperson      NUMBER;
      v_codisotel    VARCHAR2(50);
      v_attribute    XMLTYPE;
      v_encontrado   NUMBER;
      w_residentes   NUMBER;
      v_cpais        NUMBER;
      v_contador     NUMBER := 0;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT sperson
           INTO v_sperson
           FROM estassegurats
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND norden = plife;
      ELSE
         SELECT sperson
           INTO v_sperson
           FROM asegurados
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND norden = plife;
      END IF;

      v_codisotel := 'true';

      -- Acceptable country of residence
      IF ptablas = 'EST' THEN
          SELECT COUNT(*)
            INTO w_residentes
            FROM estassegurats ea, estper_personas ep, estper_detper ed
           WHERE ea.sseguro = psseguro
             AND ea.sperson = ep.sperson
             AND ep.sperson = ed.sperson
             AND ed.cpais = NVL(f_parinstalacion_n('PAIS_DEF'), 0)
             AND ea.norden = plife;
      ELSE
          SELECT COUNT(*)
            INTO w_residentes
            FROM asegurados ea, per_personas ep, per_detper ed
           WHERE ea.sseguro = psseguro
             AND ea.sperson = ep.sperson
             AND ep.sperson = ed.sperson
             AND ed.cpais = NVL(f_parinstalacion_n('PAIS_DEF'), 0)
             AND ea.norden = plife;
      END IF;

      IF w_residentes = 0 THEN
        v_contador := v_contador + 1;
      END IF;

      -- Acceptable country of birth
      BEGIN
          IF ptablas = 'EST' THEN
              SELECT p.nvalpar
                INTO v_cpais
                FROM estper_parpersonas p, estassegurats t
               WHERE t.sseguro = psseguro
                 AND t.sperson = p.sperson
                 AND p.cparam = 'PAIS_NACIMIENTO'
                 AND t.norden = plife;
          ELSE
              SELECT p.nvalpar
                INTO v_cpais
                FROM per_parpersonas p, asegurados t
               WHERE t.sseguro = psseguro
                 AND t.sperson = p.sperson
                 AND p.cparam = 'PAIS_NACIMIENTO'
                 AND t.norden = plife;
          END IF;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
               NULL;
      END;

      IF v_cpais IS NOT NULL THEN
          BEGIN
             SELECT 1
               INTO v_encontrado
               FROM detvalores
              WHERE cvalor = 8001009
                AND cidioma = 5
                AND catribu = v_cpais;

             v_encontrado := 1;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                v_encontrado := 0;
          END;

          IF v_encontrado = 0 THEN
            v_contador := v_contador + 1;
          END IF;
      ELSE
          v_contador := v_contador + 1;
      END IF;

      -- Acceptable country of nationality
      IF ptablas = 'EST' THEN
        FOR regs IN (SELECT p.cpais
                      FROM estper_nacionalidades p, estassegurats t
                     WHERE t.sseguro = psseguro
                       AND t.sperson = p.sperson
                       AND t.norden = plife) LOOP
              BEGIN
                 SELECT 1
                   INTO v_encontrado
                   FROM detvalores
                  WHERE cvalor = 8001009
                    AND cidioma = 5
                    AND catribu = regs.cpais;

                 v_encontrado := 1;
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    v_encontrado := 0;
              END;

              IF v_encontrado = 0 THEN
                v_contador := v_contador + 1;
              END IF;
        END LOOP;
      ELSE
        FOR regs IN (SELECT p.cpais
                     FROM per_nacionalidades p, asegurados t
                    WHERE t.sseguro = psseguro
                      AND t.sperson = p.sperson
                      AND t.norden = plife) LOOP

              BEGIN
                 SELECT 1
                   INTO v_encontrado
                   FROM detvalores
                  WHERE cvalor = 8001009
                    AND cidioma = 5
                    AND catribu = regs.cpais;

                 v_encontrado := 1;
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    v_encontrado := 0;
              END;

              IF v_encontrado = 0 THEN
                v_contador := v_contador + 1;
              END IF;
        END LOOP;
      END IF;

      -- Acceptable country of work
      BEGIN
          IF ptablas = 'EST' THEN
              SELECT p.nvalpar
                INTO v_cpais
                FROM estper_parpersonas p, estassegurats t
               WHERE t.sseguro = psseguro
                 AND t.sperson = p.sperson
                 AND p.cparam = 'PAIS_TRABAJO'
                 AND t.norden = plife;
          ELSE
              SELECT p.nvalpar
                INTO v_cpais
                FROM per_parpersonas p, asegurados t
               WHERE t.sseguro = psseguro
                 AND t.sperson = p.sperson
                 AND p.cparam = 'PAIS_TRABAJO'
                 AND t.norden = plife;
          END IF;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
               NULL;
      END;

      IF v_cpais IS NOT NULL THEN
          BEGIN
             SELECT 1
               INTO v_encontrado
               FROM detvalores
              WHERE cvalor = 8001009
                AND cidioma = 5
                AND catribu = v_cpais;

             v_encontrado := 1;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                v_encontrado := 0;
          END;

          IF v_encontrado = 0 THEN
            v_contador := v_contador + 1;
          END IF;
      ELSE
          v_contador := v_contador + 1;
      END IF;

      IF v_contador > 0 THEN
        v_codisotel := 'false';
      END IF;

      SELECT XMLELEMENT("attribute",
                        xmlattributes('ACCEPTABLE_COUNTRY' AS "name",
                                      v_codisotel AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('**** 3 SQLERRM = ' || SQLERRM);
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_attributecountry', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributecountry;

   FUNCTION f_get_attributesmoker(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_crespue      pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
      v_cpregun      pregunseg.cpregun%TYPE;
      v_fumador      VARCHAR2(1);
   BEGIN
      IF plife = 1 THEN
         v_cpregun := 1902;
      ELSIF plife = 2 THEN
         v_cpregun := 1904;
      END IF;

      v_res := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, v_cpregun, ptablas, v_crespue);

      IF v_res <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributesmoker', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
      END IF;

      v_fumador := pac_int_online.f_obtener_valor_emp(TO_CHAR(pcempres), 'SMOKER_STATUS',
                                                      v_crespue);

      SELECT XMLELEMENT("attribute",
                        xmlattributes('SMOKER_STATUS' AS "name", v_fumador AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributesmoker', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributesmoker;

   FUNCTION f_get_attributesmoker_last2(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_crespue      pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
      v_cpregun      pregunseg.cpregun%TYPE;
      v_fumador      NUMBER;
      v_fumador_str  VARCHAR2(10);
   BEGIN
      IF plife = 1 THEN
         v_cpregun := 1902;
      ELSIF plife = 2 THEN
         v_cpregun := 1904;
      END IF;

      v_res := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, v_cpregun, ptablas, v_crespue);

      IF v_res <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributesmoker_last2', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
      END IF;

      v_fumador := pac_int_online.f_obtener_valor_emp(TO_CHAR(pcempres), 'SMOKER_STATUS',
                                                      v_crespue);

      IF v_fumador = 3 THEN
        v_fumador_str := 'true';
      ELSE
        v_fumador_str := 'false';
      END IF;

      SELECT XMLELEMENT("attribute",
                        xmlattributes('SMOKED_LAST_2_YEARS' AS "name", v_fumador_str AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributesmoker_last2', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributesmoker_last2;

   FUNCTION f_get_attributerisk_types(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN XMLTYPE IS
      v_codigaran    VARCHAR2(200);
      v_codigos      VARCHAR(200) := '';
      v_first        BOOLEAN := TRUE;
      v_attribute    XMLTYPE;
   BEGIN
      IF ptablas = 'EST' THEN
         FOR regs IN (SELECT cgarant
                        FROM estgaranseg
                       WHERE sseguro = psseguro
                         AND nriesgo = pnriesgo
                         AND cobliga = 1
                         AND nmovimi = pnmovimi) LOOP

            BEGIN
               v_codigaran := pac_int_online.f_obtener_valor_emp(TO_CHAR(pcempres),
                                                                 'RISK_TYPES2', regs.cgarant);
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  v_codigaran := NULL;
            END;

            IF v_first THEN
               v_codigos := v_codigaran;
               v_first := FALSE;
            ELSE
               IF v_codigaran IS NOT NULL THEN
                    v_codigos := v_codigos || ',' || v_codigaran;
               END IF;
            END IF;
         END LOOP;
      ELSE
         FOR regs IN (SELECT cgarant
                        FROM garanseg
                       WHERE sseguro = psseguro
                         AND nriesgo = pnriesgo
                         AND nmovimi = pnmovimi) LOOP
            BEGIN
               v_codigaran := pac_int_online.f_obtener_valor_emp(TO_CHAR(pcempres),
                                                                 'RISK_TYPES2', regs.cgarant);
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                   v_codigaran := NULL;
            END;

            IF v_first THEN
               v_codigos := v_codigaran;
               v_first := FALSE;
            ELSE
               IF v_codigaran IS NOT NULL THEN
                v_codigos := v_codigos || ',' || v_codigaran;
               END IF;
            END IF;
         END LOOP;
      END IF;

      SELECT XMLELEMENT("attribute",
                        xmlattributes('RISK_TYPES' AS "name", v_codigos AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_attributerisk_types', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributerisk_types;

   FUNCTION f_get_attributeage_band(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_crespue      pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
      v_cpregun      pregunseg.cpregun%TYPE;
      v_fumador      NUMBER;
   BEGIN
      /*IF plife = 1 THEN
         v_res := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, 1952, ptablas, v_crespue);
      ELSIF plife = 2 THEN
         v_res := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, 1957, ptablas, v_crespue);
      END IF;*/

      v_crespue := pac_albsgt_generico.f_edad_aseg(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi,
                                                   NULL, NULL, NULL, NULL, plife);
      IF v_crespue <= 45
      THEN
         v_res := 1;
      ELSIF v_crespue <= 55
      THEN
         v_res := 2;
      ELSIF v_crespue <= 100
      THEN
         v_res := 3;
      ELSE
         v_res := 0;
      END IF;

      /*IF v_res <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_attributeage_band', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
      END IF;*/

      SELECT XMLELEMENT("attribute", xmlattributes('AGE_BAND' AS "name", v_res AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_attributeage_band', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributeage_band;

   FUNCTION f_get_attributechannel(psseguro IN NUMBER, pnmovimi IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN XMLTYPE IS
      v_crespue      VARCHAR2(100);
      v_res          NUMBER;
      v_attribute    XMLTYPE;
   BEGIN
      BEGIN
         -- v_res := PAC_PREGUNTAS.F_GET_PREGUNPOLSEG(psseguro, 1953, ptablas, v_crespue);


         BEGIN
		   IF ptablas = 'EST' THEN
			  SELECT ctipadn
				INTO v_crespue
				FROM agentes_comp
			   WHERE cagente IN(SELECT s.cagente
								  FROM estseguros s
								 WHERE s.sseguro = psseguro);
		   ELSE
			  SELECT ctipadn
				INTO v_crespue
				FROM agentes_comp
			   WHERE cagente IN(SELECT s.cagente
								  FROM seguros s
								 WHERE s.sseguro = psseguro);
		   END IF;
		EXCEPTION
		   WHEN OTHERS THEN
			  v_crespue := 0;
		END;


          SELECT XMLELEMENT("attribute", xmlattributes('CHANNEL' AS "name", v_crespue AS "value"))
            INTO v_attribute
            FROM DUAL;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_attributechannel', 1,
                     'psseguro=' || psseguro || ' ptablas = ' || ptablas, SQLERRM);
         RETURN NULL;
   END f_get_attributechannel;

   FUNCTION f_get_caseid(pcaseid IN NUMBER)
      RETURN XMLTYPE IS
      v_crespue      pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
      v_cpregun      pregunseg.cpregun%TYPE;
      v_fumador      NUMBER;
   BEGIN
      --SELECT XMLELEMENT("caseID", pcaseid)
      --  INTO v_attribute
      --  FROM DUAL;  21082015

              IF pcaseid IS NULL THEN
          SELECT XMLELEMENT("caseID", pcaseid)
            INTO v_attribute
            FROM DUAL;
      ELSE
          SELECT XMLELEMENT("caseId", pcaseid)
            INTO v_attribute
            FROM DUAL;
      END IF;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_caseid', 1,
                     'pcaseid=' || pcaseid, SQLERRM);
         RETURN NULL;
   END f_get_caseid;

   FUNCTION f_get_entitytype
      RETURN XMLTYPE IS
      v_attribute    XMLTYPE;
   BEGIN
      SELECT XMLELEMENT("entityType", 'life')
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_entitytype', 1, NULL, SQLERRM);
         RETURN NULL;
   END f_get_entitytype;

   FUNCTION f_get_entityinstance
      RETURN XMLTYPE IS
      v_attribute    XMLTYPE;
   BEGIN
      SELECT XMLELEMENT("entityInstance", '1')
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_entityinstance', 1, NULL,
                     SQLERRM);
         RETURN NULL;
   END f_get_entityinstance;

   FUNCTION f_get_parameters
      RETURN XMLTYPE IS
      v_attribute    XMLTYPE;
   BEGIN
      SELECT XMLELEMENT("parameters")
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_parameters', 1, NULL, SQLERRM);
         RETURN NULL;
   END f_get_parameters;

   FUNCTION f_get_reopencase
      RETURN XMLTYPE IS
      v_attribute    XMLTYPE;
   BEGIN
      SELECT XMLELEMENT("reopenCase", 'true')
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_reopencase', 1, NULL, SQLERRM);
         RETURN NULL;
   END f_get_reopencase;

   FUNCTION f_get_function(pcaseid IN NUMBER, pxml IN XMLTYPE)
      RETURN XMLTYPE IS
      v_crespue      pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
      v_cpregun      pregunseg.cpregun%TYPE;
      v_fumador      NUMBER;
   BEGIN
      IF pcaseid IS NULL THEN
         SELECT XMLELEMENT("CreateCaseRequestBody", pxml)
           INTO v_attribute
           FROM DUAL;
      ELSE
         SELECT XMLELEMENT("UpdateCaseRequestBody", pxml)
           INTO v_attribute
           FROM DUAL;
      END IF;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_function', 1,
                     'pcaseid=' || pcaseid, SQLERRM);
         RETURN NULL;
   END f_get_function;

   FUNCTION f_get_function_if02(pcaseid IN NUMBER, pxml IN XMLTYPE)
      RETURN XMLTYPE IS
      v_crespue      pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
      v_cpregun      pregunseg.cpregun%TYPE;
      v_fumador      NUMBER;
   BEGIN
      SELECT XMLELEMENT("UnderwriteCaseRequestBody", pxml)
      INTO v_attribute
      FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_function_if02', 1,
                     'pcaseid=' || pcaseid, SQLERRM);
         RETURN NULL;
   END f_get_function_if02;

   FUNCTION f_get_case(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN XMLTYPE IS
      v_case         XMLTYPE;
   BEGIN
      SELECT XMLELEMENT("caseXML",
                        XMLCDATA(XMLSERIALIZE(CONTENT XMLROOT(XMLELEMENT("case",
                                            XMLCONCAT(pac_underwriting.f_get_caseproperties(psseguro, ptablas),
                                                      pac_underwriting.f_get_casedata(pcempres, psseguro,
                                                                     pnriesgo, pnmovimi,
                                                                     pfefecto, ptablas))), VERSION '1.0'))))
        INTO v_case
        FROM DUAL;

      RETURN v_case;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('**** SQLERRM = ' || SQLERRM);
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_case', 1,
                     'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                     || ' ptablas = ' || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_case;

   FUNCTION f_get_disability_present(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN XMLTYPE IS
      v_crespue      pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
      v_trobat_num   NUMBER := 0;
      v_trobat       VARCHAR2(50) := 'false';
      v_codigaran    NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         FOR regs IN (SELECT cgarant
                        FROM estgaranseg
                       WHERE sseguro = psseguro
                         AND nriesgo = pnriesgo
                         AND cobliga = 1
                         AND nmovimi = pnmovimi) LOOP
            BEGIN
               v_codigaran := pac_int_online.f_obtener_valor_emp(TO_CHAR(pcempres),
                                                                 'RISK_TYPES', regs.cgarant);
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  v_codigaran := NULL;
            END;

            IF v_codigaran IS NOT NULL THEN
                IF v_codigaran = 3 THEN
                   v_trobat_num := 1;
                END IF;
            END IF;
         END LOOP;
      ELSE
         FOR regs IN (SELECT cgarant
                        FROM garanseg
                       WHERE sseguro = psseguro
                         AND nriesgo = pnriesgo
                         AND nmovimi = pnmovimi) LOOP
            BEGIN
               v_codigaran := pac_int_online.f_obtener_valor_emp(TO_CHAR(pcempres),
                                                                 'RISK_TYPES', regs.cgarant);
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  v_codigaran := NULL;
            END;

            IF v_codigaran IS NOT NULL THEN
                IF v_codigaran = 3 THEN
                   v_trobat_num := 1;
                END IF;
            END IF;
         END LOOP;
      END IF;

      IF v_trobat_num = 1 THEN
        v_trobat := 'true';
      END IF;

      SELECT XMLELEMENT("attribute",
                        xmlattributes('DISABILITY_PRESENT' AS "name", v_trobat AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_disability_present', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' pnmovimi = '
                     || pnmovimi || ' ptablas = ' || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_disability_present;

   FUNCTION f_get_risk_lifeinfo(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      picapital IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_case         XMLTYPE;
      v_crespue_1908 pregungaranseg.crespue%TYPE;
      v_crespue_1909 pregungaranseg.crespue%TYPE;
      v_crespue_1921 pregungaranseg.crespue%TYPE;
      v_crespue_1922 pregungaranseg.crespue%TYPE;
      v_res          NUMBER;
      v_current_sum  XMLTYPE;
      v_total_sum    XMLTYPE;
      v_total_ppl    XMLTYPE;
      v_total_pml    XMLTYPE;
      v_aggregate    XMLTYPE;
      v_total_sum_at_risk NUMBER := 0;
      v_total_sum_at_risk_pr NUMBER := 0;
      v_prev_policy NUMBER := 0;
      v_ssegpol      NUMBER;
      v_sproduc      NUMBER;
      v_fefecto      DATE;
      v_sperson      NUMBER;
      v_sperreal     NUMBER;
      v_nnumide      PER_PERSONAS.NNUMIDE%TYPE;
      v_codigaran    int_codigos_emp.cvalemp%TYPE;
      v_total_sumatrisk XMLTYPE;
      v_total_v_prev_policy XMLTYPE;
      v_sum_applied_for XMLTYPE;
      v_total_sum_nml NUMBER;
      v_total_sum_nml_pr NUMBER;
      v_numaseg_declined NUMBER;
      v_prev_postpone_decl XMLTYPE;
      v_prev_loading     XMLTYPE;
      v_total_prev_extra NUMBER;
      v_total_prev_pload NUMBER;
      v_prev_mevidence_valid NUMBER;
      v_cpregun_extra NUMBER;
      v_cpregun_pload NUMBER;
      v_prev_mevidencev XMLTYPE;
   BEGIN
      -------------------------
      -- CURRENT_SUM_ASSURED --
      -------------------------
      SELECT XMLELEMENT("attribute",
                        xmlattributes('CURRENT_SUM_ASSURED' AS "name", picapital AS "value"))
        INTO v_current_sum
        FROM DUAL;

      -------------------------
      --- TOTAL_SUM_AT_RISK ---
      -------------------------
      IF ptablas = 'EST' THEN
         SELECT ssegpol, sproduc, fefecto
         INTO   v_ssegpol, v_sproduc, v_fefecto
         FROM   estseguros
          WHERE sseguro = psseguro;

         SELECT sperson, pac_persona.f_sperson_spereal(sperson) sperreal
         INTO v_sperson, v_sperreal
         FROM estassegurats
         WHERE sseguro = psseguro
           AND norden = plife;

         SELECT nnumide
         INTO v_nnumide
         FROM estper_personas
         WHERE sperson = v_sperson;

      ELSE
         SELECT sseguro, sproduc, fefecto
         INTO   v_ssegpol, v_sproduc, v_fefecto
         FROM   seguros
          WHERE sseguro = psseguro;

         SELECT sperson sperreal
         INTO v_sperreal
         FROM asegurados
         WHERE sseguro = psseguro
           AND norden = plife;

         SELECT nnumide
         INTO v_nnumide
         FROM per_personas
         WHERE sperson = v_sperreal;
      END IF;

      -- C¿mulo de p¿lizas de iAXIS
      SELECT NVL(SUM (g.icapital), 0) icapital
      INTO v_total_sum_at_risk
      FROM seguros s, garanseg g, asegurados r
      WHERE s.sseguro = g.sseguro
        AND s.sseguro = r.sseguro
        AND s.csituac IN(0, 4, 5)
        AND s.creteni NOT IN(3, 4)
        AND g.ffinefe IS NULL
        AND g.nriesgo = r.nriesgo
        AND r.sperson = v_sperreal
        AND s.sseguro <> v_ssegpol
        AND g.cgarant = pcgarant;

      BEGIN
          v_codigaran := pac_int_online.f_obtener_valor_emp(TO_CHAR(pcempres), 'RISK_TYPES2', pcgarant);
      EXCEPTION
          WHEN TOO_MANY_ROWS THEN
              v_codigaran := NULL;
      END;

      -- Cúmulo de pólizas de Peritus
      SELECT NVL(SUM(total_si_on_risk), 0)
        INTO v_total_sum_at_risk_pr
        FROM accumulation
       WHERE identity_document LIKE '%' || v_nnumide || '%'
         AND LOWER(risk_types) LIKE '%' || LOWER(v_codigaran) || '%';

      v_total_sum_at_risk := v_total_sum_at_risk + v_total_sum_at_risk_pr + picapital;

      SELECT XMLELEMENT("attribute",
                        xmlattributes('TOTAL_SUM_AT_RISK' AS "name", v_total_sum_at_risk AS "value"))
        INTO v_total_sumatrisk
        FROM DUAL;

      SELECT COUNT(*)
      INTO v_prev_policy
      FROM seguros s, garanseg g, asegurados r
      WHERE s.sseguro = g.sseguro
        AND s.sseguro = r.sseguro
        AND s.csituac IN(0, 4, 5)
        AND s.creteni NOT IN(3, 4)
        AND g.ffinefe IS NULL
        AND g.nriesgo = r.nriesgo
        AND r.sperson = v_sperreal
        AND s.sseguro <> v_ssegpol
        AND g.cgarant = pcgarant;

      IF v_prev_policy > 0 THEN
		      SELECT XMLELEMENT("attribute",
                        xmlattributes('PREV_POLICY' AS "name", 'true' AS "value"))
        INTO v_total_v_prev_policy
        FROM DUAL;
      ELSE
		      SELECT XMLELEMENT("attribute",
                        xmlattributes('PREV_POLICY' AS "name", 'false' AS "value"))
        INTO v_total_v_prev_policy
        FROM DUAL;
      END IF;



      -------------------------
      ---- SUM_APPLIED_FOR ----
      -------------------------
      SELECT XMLELEMENT("attribute",
                        xmlattributes('SUM_APPLIED_FOR' AS "name", picapital AS "value"))
        INTO v_sum_applied_for
        FROM DUAL;

      -------------------------
      ----- TOTAL_SUM_NML -----
      -------------------------

      -- Cúmulo de pólizas de iAXIS - Regla 1 - 5 años
      SELECT SUM(CASE
                    WHEN(MONTHS_BETWEEN(TRUNC(f_sysdate), (SELECT NVL(femisio, fmovimi)
                                                      FROM movseguro m
                                                     WHERE m.sseguro = s.sseguro
                                                       AND m.cmotmov = 100)) / 12) < 1 THEN g.icapital
                    WHEN(MONTHS_BETWEEN(TRUNC(f_sysdate), (SELECT NVL(femisio, fmovimi)
                                                      FROM movseguro m
                                                     WHERE m.sseguro = s.sseguro
                                                       AND m.cmotmov = 100)) / 12) >= 1
                    AND(MONTHS_BETWEEN(TRUNC(f_sysdate), (SELECT NVL(femisio, fmovimi)
                                                     FROM movseguro m
                                                    WHERE m.sseguro = s.sseguro
                                                      AND m.cmotmov = 100)) / 12) < 5 THEN 0.5
                                                                                           * g.icapital
                    ELSE 0
                 END) icapital
        INTO v_total_sum_nml
        FROM seguros s, garanseg g, asegurados r
       WHERE s.sseguro = g.sseguro
         AND s.sseguro = r.sseguro
         AND s.csituac IN(0, 4, 5)
         AND s.creteni NOT IN (3, 4)
         AND g.ffinefe IS NULL
         AND g.nriesgo = r.nriesgo
         AND r.sperson = v_sperreal
         AND s.sseguro <> v_ssegpol
         AND g.cgarant = pcgarant;

      -- Cúmulo de pólizas de Peritus
      SELECT NVL(SUM(evidence_on), 0)
        INTO v_total_sum_nml_pr
        FROM accumulation
       WHERE identity_document LIKE '%' || v_nnumide || '%'
         AND LOWER(risk_types) LIKE '%' || LOWER(v_codigaran) || '%';

        --v_total_sum_nml := NVL(v_total_sum_nml, 0) + v_total_sum_nml_pr;

        v_total_sum_nml := NVL(v_total_sum_nml, 0) + v_total_sum_nml_pr + picapital;-- BUG 37574/215983

      SELECT XMLELEMENT("attribute",
                        xmlattributes('TOTAL_SUM_NML' AS "name", v_total_sum_nml AS "value"))
        INTO v_total_sum
        FROM DUAL;

      ---------------------------------------
      --- PREV_POSTPONE DECLINE_EXCLUSION ---
      ---------------------------------------
      SELECT COUNT(DISTINCT r.sseguro)
        INTO v_numaseg_declined
        FROM asegurados r, per_personas p, seguros s
       WHERE p.nnumide = v_nnumide
         AND r.sperson = p.sperson
         AND r.sseguro <> v_ssegpol
         AND s.sseguro = r.sseguro
         AND s.csituac = 4
         AND(s.creteni = 3
             OR(s.creteni = 2
                AND s.fcancel <> ADD_MONTHS(s.fefecto,
                                            NVL(f_parproductos_v(s.sproduc, 'MESES_PROPOST_VALIDA'),
                                                0))));

      IF v_numaseg_declined > 0 THEN
          SELECT XMLELEMENT("attribute",
                            xmlattributes('PREV_POSTPONE_DECLINE_EXCLUSION' AS "name", 'true' AS "value"))
            INTO v_prev_postpone_decl
            FROM DUAL;
      ELSE
          SELECT XMLELEMENT("attribute",
                            xmlattributes('PREV_POSTPONE_DECLINE_EXCLUSION' AS "name", 'false' AS "value"))
            INTO v_prev_postpone_decl
            FROM DUAL;
      END IF;

      --------------------
      --- PREV_LOADING ---
      --------------------
      IF v_codigaran = 'Lif' THEN

          IF plife = 1 THEN
             v_cpregun_extra := 1908;
             v_cpregun_pload := 1921;
          ELSE
             v_cpregun_extra := 1909;
             v_cpregun_pload := 1922;
          END IF;

          SELECT COUNT(*)
           INTO v_total_prev_extra
            FROM seguros s, garanseg g, asegurados r
           WHERE s.sseguro = g.sseguro
             AND s.sseguro = r.sseguro
             AND s.csituac IN(0, 4, 5)
             AND s.creteni NOT IN(3, 4)
             AND g.ffinefe IS NULL
             AND g.nriesgo = r.nriesgo
             AND r.sperson = v_sperreal
             AND s.sseguro <> v_ssegpol
             AND g.cgarant = pcgarant
             AND EXISTS (SELECT 1
                         FROM pregungaranseg p
                         WHERE p.sseguro = g.sseguro
                           AND p.nmovimi = g.nmovimi
                           AND p.cgarant = g.cgarant
                           AND p.nriesgo = g.nriesgo
                           AND p.cpregun = v_cpregun_extra
                           AND p.crespue <> 0);


          SELECT COUNT(*)
           INTO v_total_prev_pload
            FROM seguros s, garanseg g, asegurados r
           WHERE s.sseguro = g.sseguro
             AND s.sseguro = r.sseguro
             AND s.csituac IN(0, 4, 5)
             AND s.creteni NOT IN(3, 4)
             AND g.ffinefe IS NULL
             AND g.nriesgo = r.nriesgo
             AND r.sperson = v_sperreal
             AND s.sseguro <> v_ssegpol
             AND g.cgarant = pcgarant
             AND EXISTS (SELECT 1
                         FROM pregungaranseg p
                         WHERE p.sseguro = g.sseguro
                           AND p.nmovimi = g.nmovimi
                           AND p.cgarant = g.cgarant
                           AND p.nriesgo = g.nriesgo
                           AND p.cpregun = v_cpregun_pload
                           AND p.crespue <> 0);

          IF v_total_prev_extra > 0 OR v_total_prev_pload > 0 THEN
              SELECT XMLELEMENT("attribute",
                                xmlattributes('PREV_LOADING' AS "name", '1' AS "value"))
                INTO v_prev_loading
                FROM DUAL;
          ELSE
              SELECT XMLELEMENT("attribute",
                                xmlattributes('PREV_LOADING' AS "name", '0' AS "value"))
                INTO v_prev_loading
                FROM DUAL;
          END IF;
      ELSIF v_codigaran = 'ADB' THEN

          IF plife = 1 THEN
             v_cpregun_pload := 1912;
          ELSE
             v_cpregun_pload := 1913;
          END IF;

          SELECT COUNT(*)
           INTO v_total_prev_pload
            FROM seguros s, garanseg g, asegurados r
           WHERE s.sseguro = g.sseguro
             AND s.sseguro = r.sseguro
             AND s.csituac IN(0, 4, 5)
             AND s.creteni NOT IN(3, 4)
             AND g.ffinefe IS NULL
             AND g.nriesgo = r.nriesgo
             AND r.sperson = v_sperreal
             AND s.sseguro <> v_ssegpol
             AND g.cgarant = pcgarant
             AND EXISTS (SELECT 1
                         FROM pregungaranseg p
                         WHERE p.sseguro = g.sseguro
                           AND p.nmovimi = g.nmovimi
                           AND p.cgarant = g.cgarant
                           AND p.nriesgo = g.nriesgo
                           AND p.cpregun = v_cpregun_pload
                           AND p.crespue > 0);

          IF v_total_prev_pload > 0 THEN
              SELECT XMLELEMENT("attribute",
                                xmlattributes('PREV_LOADING' AS "name", '1' AS "value"))
                INTO v_prev_loading
                FROM DUAL;
          ELSE
              SELECT XMLELEMENT("attribute",
                                xmlattributes('PREV_LOADING' AS "name", '0' AS "value"))
                INTO v_prev_loading
                FROM DUAL;
          END IF;
      ELSIF v_codigaran IN ('ADisB', 'Dis') THEN

          IF plife = 1 THEN
             v_cpregun_pload := 1914;
          ELSE
             v_cpregun_pload := 1915;
          END IF;

          SELECT COUNT(*)
           INTO v_total_prev_pload
            FROM seguros s, garanseg g, asegurados r
           WHERE s.sseguro = g.sseguro
             AND s.sseguro = r.sseguro
             AND s.csituac IN(0, 4, 5)
             AND s.creteni NOT IN(3, 4)
             AND g.ffinefe IS NULL
             AND g.nriesgo = r.nriesgo
             AND r.sperson = v_sperreal
             AND s.sseguro <> v_ssegpol
             AND g.cgarant = pcgarant
             AND EXISTS (SELECT 1
                         FROM pregungaranseg p
                         WHERE p.sseguro = g.sseguro
                           AND p.nmovimi = g.nmovimi
                           AND p.cgarant = g.cgarant
                           AND p.nriesgo = g.nriesgo
                           AND p.cpregun = v_cpregun_pload
                           AND p.crespue > 0);

          IF v_total_prev_pload > 0 THEN
              SELECT XMLELEMENT("attribute",
                                xmlattributes('PREV_LOADING' AS "name", '1' AS "value"))
                INTO v_prev_loading
                FROM DUAL;
          ELSE
              SELECT XMLELEMENT("attribute",
                                xmlattributes('PREV_LOADING' AS "name", '0' AS "value"))
                INTO v_prev_loading
                FROM DUAL;
          END IF;
      END IF;

      -----------------------------------
      --- PREV_MEDICAL_EVIDENCE_VALID ---
      -----------------------------------
      SELECT COUNT(*)
      INTO v_prev_mevidence_valid
        FROM seguros s, asegurados r
       WHERE s.sseguro = r.sseguro
         AND s.csituac IN(0, 4, 5)
         AND s.creteni = 3
         AND r.sperson = v_sperreal
         AND s.sseguro <> v_ssegpol
         AND EXISTS (SELECT 1
                     FROM psu_retenidas p
                     WHERE p.sseguro = s.sseguro
                       AND p.nmovimi = 1
                       AND cdetmotrec = 399);

      IF v_prev_mevidence_valid > 0 THEN
          SELECT XMLELEMENT("attribute",
                            xmlattributes('PREV_MEDICAL_EVIDENCE_VALID' AS "name", 'true' AS "value"))
            INTO v_prev_mevidencev
            FROM DUAL;
      ELSE
          SELECT XMLELEMENT("attribute",
                            xmlattributes('PREV_MEDICAL_EVIDENCE_VALID' AS "name", 'false' AS "value"))
            INTO v_prev_mevidencev
            FROM DUAL;
      END IF;




      IF v_codigaran IS NOT NULL THEN
          SELECT XMLELEMENT("aggregate",
                            xmlattributes('RISK_BASED_VALUES' AS "type", v_codigaran AS "name"),
                            XMLCONCAT(v_current_sum, v_total_sumatrisk, v_total_v_prev_policy, v_sum_applied_for, v_total_sum,
                                      v_prev_postpone_decl, v_prev_loading, v_prev_mevidencev))
            INTO v_aggregate
            FROM DUAL;
      END IF;

      RETURN v_aggregate;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_risk_lifeinfo', 1,
                     'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pcgarant = ' || pcgarant
                     || ' picapital = ' || picapital || ' ptablas = ' || ptablas
                     || ' plife = ' || plife,
                     SQLERRM);
         RETURN NULL;
   END f_get_risk_lifeinfo;

   FUNCTION f_get_risk_based_values(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_codigaran    VARCHAR2(120);
      v_codigos      VARCHAR(200) := '';
      v_first        BOOLEAN := TRUE;
      v_risk_based   XMLTYPE;
      v_aggregate    XMLTYPE;
      v_res          NUMBER;
      v_sproduc      NUMBER;
      v_aux          NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         FOR regs IN (SELECT cgarant, icapital
                        FROM estgaranseg
                       WHERE sseguro = psseguro
                         AND nriesgo = pnriesgo
                         AND cobliga = 1
                         AND nmovimi = pnmovimi) LOOP

                 SELECT sproduc
                 INTO   v_sproduc
                 FROM   estseguros
                  WHERE sseguro = psseguro;

                 IF v_sproduc = 1904 THEN

                     v_aux := pac_preguntas.f_get_pregunseg(
                                            psseguro,
                                            pnriesgo,
                                            1940,
                                            'EST',
                                            v_res);

                 ELSE
                    v_res := regs.icapital;
                 END IF;


                v_aggregate := pac_underwriting.f_get_risk_lifeinfo(pcempres, psseguro, pnriesgo,
                                                                    pnmovimi, regs.cgarant,
                                                                    v_res, ptablas, plife);

                IF v_aggregate IS NOT NULL THEN
                    IF v_first THEN
                       v_risk_based := v_aggregate;
                       v_first := FALSE;
                    ELSE
                       SELECT XMLCONCAT(v_risk_based, v_aggregate)
                         INTO v_risk_based
                         FROM DUAL;
                    END IF;
                END IF;
         END LOOP;
      ELSE
         FOR regs IN (SELECT cgarant, icapital
                        FROM garanseg
                       WHERE sseguro = psseguro
                         AND nriesgo = pnriesgo
                         AND nmovimi = pnmovimi) LOOP
                v_aggregate := pac_underwriting.f_get_risk_lifeinfo(pcempres, psseguro, pnriesgo,
                                                                    pnmovimi, regs.cgarant,
                                                                    regs.icapital, ptablas, plife);

                IF v_aggregate IS NOT NULL THEN
                    IF v_first THEN
                       v_risk_based := v_aggregate;
                       v_first := FALSE;
                    ELSE
                       SELECT XMLCONCAT(v_risk_based, v_aggregate)
                         INTO v_risk_based
                         FROM DUAL;
                    END IF;
                END IF;
         END LOOP;
      END IF;

      RETURN v_risk_based;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('**** 4 SQLERRM = ' || SQLERRM);
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_risk_based_values', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_risk_based_values;

   FUNCTION f_get_attributealteration(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN XMLTYPE IS
      v_edad         pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
      v_alteration   BOOLEAN;
   BEGIN
      IF ptablas = 'EST' THEN
        IF pnmovimi > 1 THEN
            v_alteration := TRUE;
        ELSE
            v_alteration := FALSE;
        END IF;
      ELSE
        v_alteration := FALSE;
      END IF;

     IF v_alteration THEN

      SELECT XMLELEMENT("attribute", xmlattributes('ALTERATION' AS "name", 'true' AS "value"))
        INTO v_attribute
        FROM DUAL;
     ELSE
      SELECT XMLELEMENT("attribute", xmlattributes('ALTERATION' AS "name", 'false' AS "value"))
        INTO v_attribute
        FROM DUAL;
     END IF;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributealteration', 1,
                     'psseguro=' || psseguro || ' pnmovimi = ' || pnmovimi || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributealteration;

   FUNCTION f_get_attributebovtrustee(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN XMLTYPE IS
      v_bovtrustee   VARCHAR2(50);
      v_res          NUMBER;
      v_attribute    XMLTYPE;
   BEGIN
      v_bovtrustee := 'true';

      SELECT XMLELEMENT("attribute", xmlattributes('BOV_TRUSTEE' AS "name", v_bovtrustee AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributebovtrust', 1,
                     'psseguro=' || psseguro || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributebovtrustee;


   FUNCTION f_get_attributeinspurpose(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN XMLTYPE IS
      v_purpose   VARCHAR2(50);
      v_res          NUMBER;
      v_attribute    XMLTYPE;
      v_sproduc      NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
        SELECT sproduc
        INTO v_sproduc
        FROM estseguros
        WHERE sseguro = psseguro;
      ELSE
        SELECT sproduc
        INTO v_sproduc
        FROM seguros
        WHERE sseguro = psseguro;
      END IF;

      IF NVL(f_parproductos_v(v_sproduc, 'MATRIZ_TARIFAR'), 0) = 1 THEN
        v_purpose := 'LP'; -- Loan Protection
      ELSE
        v_purpose := 'P'; -- Private
      END IF;

      SELECT XMLELEMENT("attribute", xmlattributes('INSURANCE_PURPOSE' AS "name", v_purpose AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributeinspurpose', 1,
                     'psseguro=' || psseguro || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributeinspurpose;

   FUNCTION f_get_attributeinterviewtype(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      plife IN NUMBER DEFAULT 1)
      RETURN XMLTYPE IS
      v_purpose   VARCHAR2(50);
      v_res          NUMBER;
      v_attribute    XMLTYPE;
      v_crespue      NUMBER;
      v_suminsured   NUMBER;
      v_cuestionario NUMBER;
      v_cuestion_str VARCHAR2(50);
      v_aux          NUMBER;
      v_sproduc      NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN

         SELECT sproduc
         INTO   v_sproduc
         FROM   estseguros
          WHERE sseguro = psseguro;

         IF v_sproduc = 1904 THEN
             v_aux := pac_preguntas.f_get_pregunseg(
                                    psseguro,
                                    pnriesgo,
                                    1940,
                                    'EST',
                                    v_suminsured);

         ELSE
            SELECT icapital
            INTO v_suminsured
            FROM estgaranseg e, estseguros s, garanpro g
            WHERE e.sseguro = psseguro
              AND e.nmovimi = pnmovimi
              AND e.cobliga = 1
              AND e.sseguro = s.sseguro
              AND s.sproduc = g.sproduc
              AND e.cgarant = g.cgarant
              AND g.cbasica = 1;
         END IF;
      ELSE
        SELECT SUM(icapital)
        INTO v_suminsured
        FROM garanseg
        WHERE sseguro = psseguro
          AND nmovimi = pnmovimi;
      END IF;

      /*IF plife = 1 THEN
        v_res := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, 1952, ptablas, v_crespue);
      ELSE
        v_res := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, 1957, ptablas, v_crespue);
      END IF;*/

      v_crespue := pac_albsgt_generico.f_edad_aseg(ptablas, psseguro, pnriesgo, pfefecto, pnmovimi,
                                                   NULL, NULL, NULL, NULL, plife);
      IF v_crespue <= 45
      THEN
         v_res := 1;
      ELSIF v_crespue <= 55
      THEN
         v_res := 2;
      ELSIF v_crespue <= 100
      THEN
         v_res := 3;
      ELSE
         v_res := 0;
      END IF;

      v_cuestionario := pac_subtablas.F_VSUBTABLA(-1, 19000008, 43, 1, v_suminsured, v_res);

      IF v_cuestionario = 1 THEN
        v_cuestion_str := 'SF';
      ELSIF v_cuestionario = 2 THEN
        v_cuestion_str := 'LF';
      END IF;

      SELECT XMLELEMENT("attribute", xmlattributes('INTERVIEW_TYPE' AS "name", v_cuestion_str AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_set_attributeinterviewtype', 1,
                     'psseguro=' || psseguro || ' ptablas = ' || ptablas || ' pnriesgo = ' || pnriesgo || ' pfefecto = ' || pfefecto || ' pnmovimi = ' || pnmovimi ,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributeinterviewtype;

   FUNCTION f_get_attributeendowment(psseguro IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN XMLTYPE IS
      v_endowment    VARCHAR2(50);
      v_res          NUMBER;
      v_attribute    XMLTYPE;
   BEGIN
      v_endowment := 'false';

      SELECT XMLELEMENT("attribute", xmlattributes('ENDOWMENT' AS "name", v_endowment AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_attributeendowment', 1,
                     'psseguro=' || psseguro || ' ptablas = ' || ptablas, SQLERRM);
         RETURN NULL;
   END f_get_attributeendowment;

   /***********************************************************************
        Función que actualiza la nrenova

        param in psseguro        : Identificador de seguro.
        return                   : Number (0--> Ok, codigo --> error).
     ***********************************************************************/
   FUNCTION f_connect_undw_if01(
      pcaseid IN NUMBER,
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN OB_IAX_UNDERWRT_IF01 IS
      vsinterf       NUMBER;
      vnumerr        VARCHAR2(100);
      v_sproduc      NUMBER;
      v_caseid       XMLTYPE;
      v_casexml      XMLTYPE;
      v_entitytype   XMLTYPE;
      v_entityinstance XMLTYPE;
      v_parameters   XMLTYPE;
      v_reopencase   XMLTYPE;
      v_function     XMLTYPE;
      v_xml          XMLTYPE;
      v_xml2          XMLTYPE;
      v_ninterf      int_servicios.ninterf%TYPE;
      v_cinterf      parempresas.tvalpar%TYPE;
      v_xml_respuesta CLOB;
      v_if01_xml     XMLTYPE;
      v_tmeninhost  CLOB;
      vxmlfinal CLOB;
      vobiaxudw OB_IAX_UNDERWRT_IF01;
   BEGIN
       p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_connect_undw_if01', 0,
                     'start pcaseid '||pcaseid||' pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                     || ' ptablas = ' || ptablas,
                     SQLERRM);
      --v_valida := f_valida_underwriting(psseguro, pnriesgo, pnmovimi, pfefecto, ptablas);
      IF ptablas = 'EST' THEN
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF NVL(f_parproductos_v(v_sproduc, 'WS_UNDERWRITING'), 0) = 1 THEN

         v_caseid := pac_underwriting.f_get_caseid(pcaseid);

         IF pcaseid IS NOT NULL THEN
            v_reopencase := pac_underwriting.f_get_reopencase;
         END IF;

         v_casexml := pac_underwriting.f_get_case(pcempres, psseguro, pnriesgo, pnmovimi, pfefecto, ptablas);

         v_entitytype := pac_underwriting.f_get_entitytype;
         v_entityinstance := pac_underwriting.f_get_entityinstance;
         v_parameters := pac_underwriting.f_get_parameters;

         SELECT XMLCONCAT(v_caseid, v_reopencase, v_casexml, v_entitytype, v_entityinstance,
                          v_parameters)
           INTO v_xml
           FROM DUAL;

         SELECT XMLROOT(pac_underwriting.f_get_function(pcaseid, v_xml), VERSION '1.0')
         INTO v_xml2
         FROM DUAL;

         --DBMS_OUTPUT.put_line(v_xml.getclobval);
         v_cinterf := pac_parametros.f_parempresa_t(pcempres, 'INTERFICIE_UW_IF01');

         SELECT ninterf
           INTO v_ninterf
           FROM int_servicios
          WHERE cinterf = v_cinterf;



         vxmlfinal := v_xml2.getclobval;
         vnumerr := pac_con.f_connect_estandar(pcempres, psseguro, pnmovimi, vsinterf, vnumerr,
                                               vxmlfinal, 1, v_ninterf, v_cinterf);

         IF vnumerr > 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_connect_undw_if01', 1,
                        'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                        || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                        || ' ptablas = ' || ptablas || ' vnumerr = ' || vnumerr,
                        SQLERRM);

            RETURN NULL;
         END IF;

         SELECT tmeninhost
          INTO v_tmeninhost
          FROM int_mensajes
         WHERE cinterf = v_cinterf
           AND sinterf = vsinterf;

         UPDATE int_datos_xml
         SET xml_respuesta = v_tmeninhost
         WHERE sinterf = vsinterf;

         v_if01_xml := xmltype.createxml(v_tmeninhost);

         FOR myCur IN (
              SELECT if01."caseId", if01."screensURL"
              FROM XMLTABLE(xmlnamespaces('http://schemas.xmlsoap.org/soap/envelope/' as "SOAP-ENV",
                                          'http://if01.ws.ure.allfinanz.com/' as "ns3" ),
                            '/SOAP-ENV:Envelope/SOAP-ENV:Body/ns3:CreateCaseResponseBody'
                   PASSING v_if01_xml
                   COLUMNS "caseId" INTEGER PATH '//caseId',
                           "screensURL"     VARCHAR2(400) PATH '//screensURL'
                   ) if01
                       UNION ALL  --21082015
              SELECT null "caseId", if011."screensURL"
              FROM XMLTABLE(xmlnamespaces('http://schemas.xmlsoap.org/soap/envelope/' as "SOAP-ENV",
                                          'http://if01.ws.ure.allfinanz.com/' as "ns3" ),
                            '/SOAP-ENV:Envelope/SOAP-ENV:Body/ns3:UpdateCaseResponseBody'
                   PASSING v_if01_xml
                   COLUMNS "screensURL"     VARCHAR2(400) PATH '//screensURL'
                   ) if011
          )LOOP

             vobiaxudw := ob_iax_underwrt_if01();
             vobiaxudw.caseid := nvl(myCur."caseId",pcaseid);
             vobiaxudw.screenurl := myCur."screensURL";

             IF ptablas = 'EST' THEN
             BEGIN
                INSERT INTO estriesgos_ir
                            (sseguro, nriesgo, nmovimi, cinspreq, cresultr, tperscontacto,
                             ttelcontacto, tmailcontacto, crolcontacto)
                     VALUES (psseguro, pnriesgo, pnmovimi, 1, 4, NULL,
                             NULL, NULL, NULL);
             EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                   UPDATE estriesgos_ir
                      SET cinspreq = 1,
                          cresultr = 4
                    WHERE sseguro = psseguro
                      AND nriesgo = pnriesgo
                      AND nmovimi = pnmovimi;
             END;

             BEGIN
                INSERT INTO estriesgos_ir_ordenes
                                (sseguro, nriesgo, nmovimi, cempres, sorden, cnueva, sinterf1)
                         VALUES (psseguro, pnriesgo, pnmovimi, pcempres, vobiaxudw.caseid, 1, vsinterf);
             EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                   NULL;
             END;
         ELSE
             BEGIN
                INSERT INTO riesgos_ir
                            (sseguro, nriesgo, nmovimi, cinspreq, cresultr, tperscontacto,
                             ttelcontacto, tmailcontacto, crolcontacto)
                     VALUES (psseguro, pnriesgo, pnmovimi, 1, 4, NULL,
                             NULL, NULL, NULL);
             EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                   UPDATE riesgos_ir
                      SET cinspreq = 1,
                          cresultr = 4
                    WHERE sseguro = psseguro
                      AND nriesgo = pnriesgo
                      AND nmovimi = pnmovimi;
             END;

             BEGIN
                INSERT INTO riesgos_ir_ordenes
                                (sseguro, nriesgo, nmovimi, cempres, sorden, cnueva, sinterf1)
                         VALUES (psseguro, pnriesgo, pnmovimi, pcempres, vobiaxudw.caseid, 1, vsinterf);
             EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                   NULL;
             END;
             END IF;
         END LOOP;
      END IF;

      RETURN vobiaxudw;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_connect_undw_if01', 2,
                     'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                     || ' ptablas = ' || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_connect_undw_if01;

   FUNCTION f_get_locale
      RETURN XMLTYPE IS
      v_attribute    XMLTYPE;
   BEGIN
      SELECT XMLELEMENT("Locale")
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_locale', 1, NULL, SQLERRM);
         RETURN NULL;
   END f_get_locale;

   /***********************************************************************
        Función que actualiza la nrenova

        param in psseguro        : Identificador de seguro.
        return                   : Number (0--> Ok, codigo --> error).
     ***********************************************************************/
   FUNCTION f_connect_undw_if02(
      pcaseid IN NUMBER,
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS
      vsinterf       NUMBER;
      vnumerr        VARCHAR2(100);
      v_sproduc      NUMBER;
      v_caseid       XMLTYPE;
      v_casexml      XMLTYPE;
      v_entitytype   XMLTYPE;
      v_entityinstance XMLTYPE;
      v_parameters   XMLTYPE;
      v_reopencase   XMLTYPE;
      v_function     XMLTYPE;
      v_xml          XMLTYPE;
      v_xml2          XMLTYPE;
      v_ninterf      int_servicios.ninterf%TYPE;
      v_cinterf      parempresas.tvalpar%TYPE;
      v_locale       XMLTYPE;

      v_xml_respuesta CLOB;
      v_if02_xml     XMLTYPE;
      v_tmeninhost  CLOB;
      vxmlfinal CLOB;
      vobiaxudw OB_IAX_UNDERWRT_IF01;
   BEGIN
      --v_valida := f_valida_underwriting(psseguro, pnriesgo, pnmovimi, pfefecto, ptablas);
      IF ptablas = 'EST' THEN
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF NVL(f_parproductos_v(v_sproduc, 'WS_UNDERWRITING'), 0) = 1 THEN

         SELECT XMLELEMENT("caseID", pcaseid)
         INTO v_caseid
         FROM DUAL;

         v_locale := pac_underwriting.f_get_locale;

         SELECT XMLCONCAT(v_caseid, v_locale)
           INTO v_xml
           FROM DUAL;

         SELECT XMLROOT(pac_underwriting.f_get_function_if02(pcaseid, v_xml), VERSION '1.0')
         INTO v_xml2
         FROM DUAL;

         v_cinterf := pac_parametros.f_parempresa_t(pcempres, 'INTERFICIE_UW_IF02');

         SELECT ninterf
         INTO v_ninterf
         FROM int_servicios
         WHERE cinterf = v_cinterf;

         --vxmlfinal := REPLACE(v_xml2.getclobval, 'underwriteCase', 'if02:underwriteCase');
         vxmlfinal := v_xml2.getclobval;

         vnumerr := pac_con.f_connect_estandar(pcempres, psseguro, pnmovimi, vsinterf, vnumerr,
                                               vxmlfinal, 1, v_ninterf, v_cinterf);

         IF vnumerr > 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_connect_undw_if02', 1,
                        'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                        || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                        || ' ptablas = ' || ptablas || ' vnumerr = ' || vnumerr,
                        SQLERRM);

            RETURN 1;
         END IF;

         SELECT tmeninhost
          INTO v_tmeninhost
          FROM int_mensajes
         WHERE cinterf = v_cinterf
           AND sinterf = vsinterf;

         UPDATE int_datos_xml
         SET xml_respuesta = v_tmeninhost
         WHERE sinterf = vsinterf;

         v_if02_xml := xmltype.createxml(v_tmeninhost);

         IF ptablas = 'EST' THEN
            UPDATE estriesgos_ir_ordenes
            SET sinterf2 = vsinterf
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND nmovimi = pnmovimi
              AND cempres = pcempres
              AND sorden = pcaseid;
         ELSE
            UPDATE riesgos_ir_ordenes
            SET sinterf2 = vsinterf
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND nmovimi = pnmovimi
              AND cempres = pcempres
              AND sorden = pcaseid;
         END IF;

         -- Tratamiento del Underwriting (Lectura del CaseXML de respuesta)
         vnumerr := PAC_UNDERWRITING.f_extract_questions_if02(pcaseid, pcempres, psseguro, pnriesgo,
                                                              pnmovimi, vsinterf, ptablas);
         IF vnumerr > 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_connect_undw_if02', 2,
                        'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                        || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                        || ' ptablas = ' || ptablas || ' vnumerr = ' || vnumerr,
                        SQLERRM);

            RETURN 1;
         END IF;

         -- Tratamiento del Underwriting (Lectura del CaseXML de respuesta)
         vnumerr := PAC_UNDERWRITING.f_extract_actions_if02(pcaseid, pcempres, psseguro, pnriesgo,
                                                              pnmovimi, vsinterf, ptablas);
         IF vnumerr > 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_connect_undw_if02', 2,
                        'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                        || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                        || ' ptablas = ' || ptablas || ' vnumerr = ' || vnumerr,
                        SQLERRM);

            RETURN 1;
         END IF;

         -- Tratamiento del Underwriting (Lectura del CaseXML de respuesta) enfermedades
         vnumerr := PAC_UNDERWRITING.f_extract_icd10codes_if02(pcaseid, pcempres, psseguro, pnriesgo,
                                                               pnmovimi, vsinterf, ptablas);
         --
         IF vnumerr <> 0
         THEN
            p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_extract_icd10codes_if02', 1,
                        'pcempres = ' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                        || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                        || ' vsinterf = ' || vsinterf|| ' ptablas = ' || ptablas || ' vnumerr = ' || vnumerr,
                        SQLERRM);

            RETURN 1;
         END IF;
         --

         vnumerr := PAC_UNDERWRITING.f_extract_exclusions_if02(pcaseid, pcempres, psseguro, pnriesgo,
                                                               pnmovimi, vsinterf, ptablas);
         IF vnumerr > 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_extract_exclusions_if02', 2,
                        'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                        || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                        || ' ptablas = ' || ptablas || ' vnumerr = ' || vnumerr,
                        SQLERRM);

            RETURN 1;
         END IF;


         vnumerr := PAC_UNDERWRITING.f_extract_loadings_if02(pcaseid, pcempres, psseguro, pnriesgo,
                                                             pnmovimi, vsinterf, ptablas);
         IF vnumerr > 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_extract_loadings_if02', 2,
                        'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                        || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                        || ' ptablas = ' || ptablas || ' vnumerr = ' || vnumerr,
                        SQLERRM);

            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_connect_undw_if02', 3,
                     'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pnmovimi = ' || pnmovimi || ' pfefecto = ' || pfefecto
                     || ' ptablas = ' || ptablas,
                     SQLERRM);
         RETURN 1;
   END f_connect_undw_if02;

   FUNCTION f_extract_questions_if02(
          pcaseid IN NUMBER,
          pcempres IN NUMBER,
          psseguro IN NUMBER,
          pnriesgo IN NUMBER,
          pnmovimi IN NUMBER,
          psinterf IN NUMBER,
          ptablas IN VARCHAR2 DEFAULT 'EST') RETURN NUMBER IS

       v_respuesta     CLOB;
       v_if02_xml      XMLTYPE;
       v_baseQuestions XMLTYPE;
       v_entity        XMLTYPE;
       v_disclosures   XMLTYPE;
       v_condition     VARCHAR2(500);
       v_norden        NUMBER := 1;
       --BUG 37574-214439 01/10/2015 KJSC Extraer profesion
       v_valor_1988    NUMBER;
       v_valor_1995    NUMBER;
    BEGIN
       IF ptablas = 'EST' THEN
         DELETE estbasequestion_undw
         WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cempres = pcempres
            and sorden = pcaseid;
       ELSE
         DELETE basequestion_undw
         WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cempres = pcempres
            and sorden = pcaseid;
       END IF;

       SELECT xml_respuesta
         INTO v_respuesta
         FROM int_datos_xml
        WHERE sinterf = psinterf;

       v_if02_xml := XMLTYPE.createxml(v_respuesta);



       v_entity := v_if02_xml.EXTRACT('//case/underwriting');


	   for myCurEn in ( SELECT  ent."identity"
                         FROM XMLTABLE ('//entity'
                                         PASSING v_entity
                                         COLUMNS "identity" varchar2(2000) PATH '@name' ) ent

	    )loop


       v_baseQuestions := v_if02_xml.EXTRACT('//case/underwriting/entity[@name='||myCurEn."identity"||']/baseQuestions');
       v_disclosures := v_if02_xml.EXTRACT('//case/underwriting/entity[@name='||myCurEn."identity"||']/disclosures');

       FOR myCur IN (
                 SELECT if02."code", if02."position", if02."question", if02."answer", if02."category", if02."linkedConditions"
                 FROM XMLTABLE('//baseQuestion'
                      PASSING v_baseQuestions
                      COLUMNS "code" VARCHAR2(2000) PATH '//code',
                              "position" NUMBER PATH '//position',
                              "question" VARCHAR2(2000) PATH '//question',
                              "answer" VARCHAR2(2000) PATH '//answer',
                              "category" VARCHAR2(2000) PATH '//category',
                              "linkedConditions" XMLTYPE PATH '//linkedConditions'

                      ) if02
         )LOOP
             --dbms_output.put_line('Code: ' || myCur."code");
             --dbms_output.put_line('Position: ' || myCur."position");
             --dbms_output.put_line('Category: ' || myCur."category");
             --dbms_output.put_line('Norden: ' || v_norden);
             --dbms_output.put_line('Question: ' || myCur."question");

             IF myCur."linkedConditions" IS NOT NULL THEN
                 SELECT EXTRACTVALUE(myCur."linkedConditions", '//conditionRef/@id')
                 INTO v_condition
                 FROM dual;

                 FOR myCur2 IN (
                     SELECT conditions."id", conditions."alias", conditions."decisionPath", conditions."category"
                     FROM XMLTABLE('//condition'
                          PASSING v_disclosures
                          COLUMNS "id" VARCHAR2(2000) PATH '@id',
                                  "alias" VARCHAR2(2000) PATH '//alias',
                                  "decisionPath" XMLTYPE PATH '//decisionPath',
                                  "category" VARCHAR2(2000) PATH '//category'

                          ) conditions) LOOP

                    IF UPPER(myCur2."category")  = 'OCCUPATIONAL' THEN
                        SELECT cprofes
                          INTO v_valor_1988
                          FROM profesiones
                         WHERE tprofes = myCur2."alias"
                           AND cidioma = pac_md_common.f_get_cxtidioma;

                           IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
                              AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
                            FOR j IN
                               pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
                               IF pac_iax_produccion.poliza.det_poliza.riesgos(j).preguntas IS NOT NULL
                                  AND pac_iax_produccion.poliza.det_poliza.riesgos(j).preguntas.COUNT > 0
                                THEN
                                      FOR z IN pac_iax_produccion.poliza.det_poliza.riesgos(j).preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos(j).preguntas.LAST LOOP
                                          IF myCurEn."identity" = '1' THEN
                                            IF pac_iax_produccion.poliza.det_poliza.riesgos(j).preguntas(z).cpregun = 1988 THEN
                                               pac_iax_produccion.poliza.det_poliza.riesgos(j).preguntas(z).crespue := v_valor_1988;
                                            END IF;
                                          ELSE
                                            IF pac_iax_produccion.poliza.det_poliza.riesgos(j).preguntas(z).cpregun = 1995 THEN
                                               pac_iax_produccion.poliza.det_poliza.riesgos(j).preguntas(z).crespue := v_valor_1988;
                                            END IF;
                                          END IF;
                                      END LOOP;
                               END IF;
                            END LOOP;
                         END IF;
                    END IF;

                    IF myCur2."id" = v_condition THEN

                        IF ptablas = 'EST' THEN
                            INSERT INTO estbasequestion_undw (sseguro, nriesgo, nmovimi, cempres, sorden, code,
                                                           POSITION, category, norden, question, answer,naseg)
                            VALUES
                                (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, myCur."code",
                                 myCur."position", myCur."category", v_norden, myCur."question", myCur."answer" || ' - ' || myCur2."alias",myCurEn."identity");
                        ELSE
                            INSERT INTO basequestion_undw (sseguro, nriesgo, nmovimi, cempres, sorden, code,
                                                           POSITION, category, norden, question, answer,naseg)
                            VALUES
                                (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, myCur."code",
                                 myCur."position", myCur."category", v_norden, myCur."question", myCur."answer" || ' - ' || myCur2."alias",myCurEn."identity");

                        END IF;

                        v_norden := v_norden + 1;

                        --dbms_output.put_line('Answer: ' || myCur."answer" || ' - ' || myCur2."alias");

                        IF myCur2."decisionPath" IS NOT NULL THEN

                               FOR myCur3 IN (
                                     SELECT questions."question", questions."answerText"
                                     FROM XMLTABLE('//questionStep/reflexiveQuestion'
                                          PASSING myCur2."decisionPath"
                                          COLUMNS "question" VARCHAR2(2000) PATH '//question',
                                                  "answerText" VARCHAR2(2000) PATH '//answerText'
                                          ) questions
                               )LOOP
                                    --dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
                                    --dbms_output.put_line('Code: ' || myCur."code");
                                    --dbms_output.put_line('Position: ' || myCur."position");
                                    --dbms_output.put_line('Norden: ' || v_norden);
                                    --dbms_output.put_line('Question: ' || myCur3."question");
                                    --dbms_output.put_line('Answer: ' || myCur3."answerText");

                                    IF ptablas = 'EST' THEN
                                        INSERT INTO estbasequestion_undw (sseguro, nriesgo, nmovimi, cempres, sorden, code,
                                                                       POSITION, category, norden, question, answer,naseg)
                                        VALUES
                                            (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, myCur."code",
                                             myCur."position", myCur."category", v_norden, myCur3."question", myCur3."answerText",myCurEn."identity");
                                    ELSE
                                        INSERT INTO basequestion_undw (sseguro, nriesgo, nmovimi, cempres, sorden, code,
                                                                       POSITION, category, norden, question, answer,naseg)
                                        VALUES
                                            (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, myCur."code",
                                             myCur."position", myCur."category", v_norden, myCur3."question", myCur3."answerText",myCurEn."identity");

                                    END IF;

                                    v_norden := v_norden + 1;
                               END LOOP;
                        END IF;

                        EXIT;

                    END IF;
                 END LOOP;
             ELSE
                 IF ptablas = 'EST' THEN
                     INSERT INTO estbasequestion_undw (sseguro, nriesgo, nmovimi, cempres, sorden, code,
                                                    POSITION, category, norden, question, answer,naseg)
                     VALUES
                         (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, myCur."code",
                          myCur."position", myCur."category",  v_norden, myCur."question", myCur."answer",myCurEn."identity");
                 ELSE
                     INSERT INTO basequestion_undw (sseguro, nriesgo, nmovimi, cempres, sorden, code,
                                                    POSITION, category, norden, question, answer,naseg)
                     VALUES
                         (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, myCur."code",
                          myCur."position", myCur."category",  v_norden, myCur."question", myCur."answer",myCurEn."identity");
                 END IF;

                 v_norden := v_norden + 1;

                 --dbms_output.put_line('Answer: ' || myCur."answer");
             END IF;

             --dbms_output.put_line('------------------------------------------------------------------------');
       END LOOP;


       end loop;



       RETURN 0;
    EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_extract_questions_if02', 2,
                     'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pnmovimi = ' || pnmovimi
                     || ' ptablas = ' || ptablas,
                     SQLERRM);
         RETURN 1;
    END f_extract_questions_if02;


    FUNCTION f_extract_actions_if02(
      pcaseid IN NUMBER,
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psinterf IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER IS

       v_xml CLOB;
       v_if01_xml XMLTYPE;
       v_disclosures XMLTYPE;
       v_case VARCHAR2(50) := 'CreateCaseResponseBody';
       v_code VARCHAR(2000);
       V_valida NUMBER := 0;
       v_literal VARCHAR(2000);
       v_tref VARCHAR(50) :=  'AIS Manual Underwriting: ';
       v_sorden NUMBER := 0;
       v_norden NUMBER := 1;
       v_traza NUMBER := 0;
       v_entity NUMBER := 0;
       v_asegurado VARCHAR2(100);
       v_numerr NUMBER := 0;
       mensajes t_iax_mensajes;

       TYPE t_entidad IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
       v_entidad       t_entidad;
    BEGIN
       IF ptablas = 'EST' THEN
         DELETE ESTACTIONS_UNDW
         WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cempres = pcempres
            and sorden = pcaseid;

         DELETE ESTCITAMEDICA_UNDW
         WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cais = 1;
            v_numerr :=  pac_iax_produccion.f_eliminar_citas_ais(mensajes);
       ELSE
         DELETE ACTIONS_UNDW
         WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cempres = pcempres
            and sorden = pcaseid;

         DELETE CITAMEDICA_UNDW
         WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cais = 1;
       END IF;


      SELECT xml_respuesta
         INTO v_xml
         FROM int_datos_xml
        WHERE sinterf = psinterf;

        v_traza := 1;

        v_if01_xml := xmltype.createxml(v_xml);
        v_disclosures := v_if01_xml.EXTRACT('//case/underwriting/entity');

        v_traza := 2;

        FOR myCurBase IN (SELECT if03."alias", if03."actions", if01."entity", if01."unansweredQuestions"
                            FROM XMLTABLE('//entity'
                                 PASSING v_disclosures
                                 COLUMNS "disclosures" XMLTYPE PATH 'disclosures',
                                         "entity" NUMBER PATH '@name',
                                         "unansweredQuestions" VARCHAR2(2000) PATH 'unansweredQuestions') if01,
                                 XMLTABLE('/disclosures'
                                 PASSING if01."disclosures"
                                 COLUMNS "condition" XMLTYPE PATH 'condition')if02,
                                 XMLTABLE('/condition'
                                 PASSING if02."condition"
                                 COLUMNS "alias" VARCHAR2(2000) PATH 'alias',
                                         "actions" XMLTYPE PATH  'actions'
                                ) if03)
        LOOP
            v_traza := 3;
            v_entity := myCurBase."entity";
            --

            IF NOT v_entidad.EXISTS(v_entity) THEN
              IF myCurBase."unansweredQuestions" IS NOT NULL THEN
                IF myCurBase."unansweredQuestions" = 'true' THEN
                      IF ptablas = 'EST' THEN

                        v_asegurado := NULL;

                        SELECT p.tnombre || ' ' || p.tapelli1 || ' ' || p.tapelli2
                          INTO v_asegurado
                          FROM estassegurats a, estper_detper p
                         WHERE a.sseguro = psseguro
                           AND a.sperson = p.sperson
                           AND a.norden = v_entity;

                          INSERT INTO ESTACTIONS_UNDW
                                      (sseguro, nriesgo, nmovimi, cempres, sorden, norden, action, naseg)
                               VALUES (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, v_norden, v_asegurado || ' - Unanswered Questions', v_entity);
                      ELSE
                        v_asegurado := NULL;

                        SELECT p.tnombre || ' ' || p.tapelli1 || ' ' || p.tapelli2
                          INTO v_asegurado
                          FROM asegurados a, per_detper p
                         WHERE a.sseguro = psseguro
                           AND a.sperson = p.sperson
                           AND a.norden = v_entity;

                          INSERT INTO ACTIONS_UNDW
                                      (sseguro, nriesgo, nmovimi, cempres, sorden, norden, action, naseg)
                               VALUES
                                      (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, v_norden, v_asegurado || ' - Unanswered Questions', v_entity);

                      END IF;

                      v_norden := v_norden + 1;
                END IF;
              END IF;

              v_entidad(v_entity) := 1;
           END IF;

            FOR myCur IN (SELECT if01."riskType", if01."label", if01."manualUnderwritingRequired", if01."tests", if01."postponePeriod"
                           FROM XMLTABLE('//action'
                                PASSING myCurBase."actions"
                                COLUMNS "riskType" VARCHAR2(2000) PATH '//riskType',
                                        "label" VARCHAR2(2000) PATH '//label',
                                        "manualUnderwritingRequired" VARCHAR2(2000) PATH  '//manualUnderwritingRequired',
                                        "tests" XMLTYPE PATH  '//test',
                                        "postponePeriod" VARCHAR(2000) PATH '//postponePeriod'

                          ) if01)
            LOOP
               v_traza := 4;
               v_valida := 0;

               IF myCur."manualUnderwritingRequired"  IS NOT NULL
               THEN
                    IF myCur."manualUnderwritingRequired" = 'true'
                    THEN
                      v_valida :=1;
                    END IF;

                    v_literal := myCurBase."alias";

               END IF;

               IF myCur."tests"  IS NOT NULL
               THEN
                    FOR rec IN (SELECT EXTRACTVALUE(VALUE(x), '//test/@code') code
                                FROM   TABLE(XMLSEQUENCE(EXTRACT(myCur."tests", '//test'))) x) LOOP

                        v_code := rec.code;
                        v_numerr := f_initializes_appointments(psseguro ,pnriesgo ,pnmovimi, v_code, v_entity);

                        v_valida := 2;
                        v_literal := (myCurBase."alias")||' - '||v_code;
                    END LOOP;
               END IF;

               IF myCur."postponePeriod" IS NOT NULL
               THEN
                    v_valida := 3;
                    v_literal := (myCurBase."alias")||' - '||(myCur."label")||' - '||(myCur."postponePeriod");

               END IF;


              IF v_valida <> 0 THEN

                    IF ptablas = 'EST' THEN
                        v_traza := 5;
                        --
                        v_asegurado := NULL;
                        --
                        SELECT p.tnombre || ' ' || p.tapelli1 || ' ' || p.tapelli2
                          INTO v_asegurado
                          FROM estassegurats a, estper_detper p
                         WHERE a.sseguro = psseguro
                           AND a.sperson = p.sperson
                           AND a.norden = v_entity;

                        INSERT INTO ESTACTIONS_UNDW
                                    (sseguro, nriesgo, nmovimi, cempres, sorden, norden, action, naseg)
                             VALUES (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, v_norden,v_asegurado ||' - '|| v_literal, v_entity);
                    ELSE
                        --
                        v_asegurado := NULL;
                        --
                        SELECT p.tnombre || ' ' || p.tapelli1 || ' ' || p.tapelli2
                          INTO v_asegurado
                          FROM asegurados a, per_detper p
                         WHERE a.sseguro = psseguro
                           AND a.sperson = p.sperson
                           AND a.norden = v_entity;

                        INSERT INTO ACTIONS_UNDW
                                    (sseguro, nriesgo, nmovimi, cempres, sorden, norden, action, naseg)
                             VALUES
                                    (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, v_norden, v_asegurado || ' - ' || v_literal, v_entity);

                    END IF;
                    v_norden := v_norden + 1;

              END IF;

          END LOOP;
        END LOOP;

        RETURN 0;
    EXCEPTION
      WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_extract_actions_if02', v_traza,
                     'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pnmovimi = ' || pnmovimi
                     || ' ptablas = ' || ptablas,
                     SQLERRM);
         RETURN 1;
    END f_extract_actions_if02;

   FUNCTION f_extract_exclusions_if02(
          pcaseid IN NUMBER,
          pcempres IN NUMBER,
          psseguro IN NUMBER,
          pnriesgo IN NUMBER,
          pnmovimi IN NUMBER,
          psinterf IN NUMBER,
          ptablas IN VARCHAR2 DEFAULT 'EST') RETURN NUMBER IS

    v_respuesta     CLOB;
    v_if02_xml      XMLTYPE;
    v_disclosures   XMLTYPE;
    v_case          XMLTYPE;
    v_norden        NUMBER := 1;

  BEGIN
       IF ptablas = 'EST' THEN
         DELETE estexclusiones_undw
         WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cempres = pcempres
            and sorden = pcaseid;
       ELSE
         DELETE exclusiones_undw
         WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cempres = pcempres
            and sorden = pcaseid;
       END IF;

    SELECT xml_respuesta
      INTO v_respuesta
      FROM int_datos_xml
     WHERE sinterf = psinterf;

    IF v_respuesta IS NOT NULL THEN

      v_if02_xml := XMLTYPE.createxml(v_respuesta);

      v_case := v_if02_xml.EXTRACT('//case');

      FOR myCur0 IN (
        SELECT entitys."entity",entitys."tipo"
          FROM XMLTABLE('//underwriting/entity'
               PASSING v_case
               COLUMNS "entity" XMLTYPE PATH '/',
                       "tipo"   VARCHAR2(2000) PATH '@name'
               ) entitys) LOOP

          FOR myCur1 IN (
            SELECT conditions."actions",conditions."manualActions"
              FROM XMLTABLE('//condition'
                   PASSING myCur0."entity"
                   COLUMNS "actions" XMLTYPE PATH '//actions',
                           "manualActions" XMLTYPE PATH '//manualActions'
                   ) conditions) LOOP

             IF myCur1."actions" IS NOT NULL THEN

                FOR myCur2 IN (
                 SELECT action."codegar",action."label",action."codexclus"
                   FROM XMLTABLE('//action'
                        PASSING myCur1."actions"
                        COLUMNS "codegar"   VARCHAR2(2000) PATH '//riskType/@code',
                                "label"     VARCHAR2(2000) PATH '//label',
                                "codexclus" VARCHAR2(2000) PATH '//exclusions/exclusion/@code'
                        ) action) LOOP

                      IF myCur2."codexclus" IS NOT NULL THEN
                        IF ptablas = 'EST' THEN
                           INSERT INTO estexclusiones_undw(sseguro, nriesgo, nmovimi, cempres, sorden, norden, codegar, label, codexclus, naseg)
                           VALUES(psseguro, pnriesgo, pnmovimi, pcempres, pcaseid,v_norden,myCur2."codegar",myCur2."label",myCur2."codexclus", myCur0."tipo");
                        ELSE
                           INSERT INTO exclusiones_undw(sseguro, nriesgo, nmovimi, cempres, sorden, norden, codegar, label, codexclus, naseg)
                           VALUES(psseguro, pnriesgo, pnmovimi, pcempres, pcaseid,v_norden,myCur2."codegar",myCur2."label",myCur2."codexclus", myCur0."tipo");
                        END IF;

                        v_norden := v_norden + 1;
                      END IF;

                END LOOP;

             END IF;

             IF myCur1."manualActions" IS NOT NULL THEN

                FOR myCur2 IN (
                 SELECT action."codegar",action."label",action."codexclus"
                   FROM XMLTABLE('//action'
                        PASSING myCur1."manualActions"
                        COLUMNS "codegar"   VARCHAR2(2000) PATH '//riskType/@code',
                                "label"     VARCHAR2(2000) PATH '//label',
                                "codexclus" VARCHAR2(2000) PATH '//exclusions/exclusion/@code'
                        ) action) LOOP

                      IF myCur2."codexclus" IS NOT NULL THEN
                        IF ptablas = 'EST' THEN
                           INSERT INTO estexclusiones_undw(sseguro, nriesgo, nmovimi, cempres, sorden, norden, codegar, label, codexclus, naseg)
                           VALUES(psseguro, pnriesgo, pnmovimi, pcempres, pcaseid,v_norden,myCur2."codegar",myCur2."label",myCur2."codexclus", myCur0."tipo");
                        ELSE
                           INSERT INTO exclusiones_undw(sseguro, nriesgo, nmovimi, cempres, sorden, norden, codegar, label, codexclus, naseg)
                           VALUES(psseguro, pnriesgo, pnmovimi, pcempres, pcaseid,v_norden,myCur2."codegar",myCur2."label",myCur2."codexclus", myCur0."tipo");
                        END IF;

                        v_norden := v_norden + 1;
                      END IF;

                END LOOP;
             END IF;
          END LOOP;
       END LOOP;
    END IF;
    RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_extract_exclusions_if02', 2,
                     'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pnmovimi = ' || pnmovimi
                     || ' ptablas = ' || ptablas,
                     SQLERRM);
         RETURN 1;
  END f_extract_exclusions_if02;

  FUNCTION f_extract_icd10codes_if02(
      pcaseid    IN   NUMBER,
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      psinterf   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST')
     RETURN NUMBER IS
     --
     v_respuesta CLOB;
     v_icd10_xml xmltype;
     v_disclosures xmltype;
     v_norden NUMBER := 1;
     vobject VARCHAR2(50) := 'PAC_UNDERWRITING.f_extract_icd10codes_if02';
     vparam  VARCHAR2(200):= 'pcaseid: ' || pcaseid || ' - pcempres: ' || pcempres || ' - psseguro: ' || psseguro || ' - pnriesgo: ' || pnriesgo
                             || ' - pnmovimi: ' || pnmovimi || ' - psinterf: ' || psinterf || ' - ptablas: ' || ptablas;
     --
  BEGIN

       IF ptablas = 'EST' THEN
         DELETE estenfermedades_undw
         WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cempres = pcempres
            and sorden = pcaseid;
       ELSE
         DELETE enfermedades_undw
         WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cempres = pcempres
            and sorden = pcaseid;
       END IF;

    --
    BEGIN
      SELECT xml_respuesta
        INTO v_respuesta
        FROM INT_DATOS_XML
       WHERE sinterf = psinterf;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         v_respuesta := NULL;
    END;
    --
    IF v_respuesta IS NOT NULL
    THEN
      --
      v_icd10_xml := XMLTYPE.createxml(v_respuesta);
      v_disclosures := v_icd10_xml.EXTRACT('//case/underwriting/entity/disclosures');
      --
      FOR enf IN (SELECT icd10."referenceCode", icd10."alias"
                    FROM XMLTABLE('//condition'
                         PASSING v_disclosures
                         COLUMNS "category" VARCHAR(50) PATH 'category/@code',
                                 "alias" VARCHAR2(100) PATH 'alias',
                                 "referenceCode" VARCHAR2(100) PATH 'alias/@referenceCode') icd10
                   WHERE icd10."category" = 'MEDICAL')
      LOOP
         --
         IF ptablas = 'EST'
         THEN
            --
            INSERT INTO estenfermedades_undw(sseguro, nriesgo, nmovimi, cempres, sorden ,norden ,cindex ,codenf ,desenf)
                 VALUES(psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, v_norden, enfbase.nextval, enf."referenceCode", enf."alias");
            --
         ELSE
            --
            INSERT INTO enfermedades_undw(sseguro, nriesgo, nmovimi, cempres, sorden ,norden , cindex, codenf ,desenf)
                 VALUES(psseguro, pnriesgo, pnmovimi, pcempres, pcaseid,v_norden, enfbase.nextval, enf."referenceCode", enf."alias");
            --
        END IF;
        --
        v_norden := v_norden + 1;
        --
      END LOOP;
      --
    END IF;
    --
    RETURN 0;
    --
  EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 1, vparam, SQLERRM);
         RETURN 1;
  END f_extract_icd10codes_if02;

  FUNCTION f_setrechazo_icd10codes(
     psseguro IN seguros.sseguro  %TYPE,
     pnmovimi IN movseguro.nmovimi%TYPE,
     pcindex  IN t_iax_info,
     mensajes    OUT t_iax_mensajes)
     RETURN NUMBER
  IS
     --
     vpasexec    NUMBER(5) := 1;
     vobjectname VARCHAR2(500) := 'PAC_UNDERWRITING.f_setrechazo_icd10codes';
     vparam      VARCHAR2(1000) := 'parámetros - psseguro : ' || psseguro || ' pnmovimi ' || pnmovimi;
     --
  BEGIN
    --
    FOR valores IN pcindex.first .. pcindex.last
    LOOP
       --
       INSERT INTO icd_declina_undw (sseguro, nmovimi, cindex)
            VALUES (psseguro, pnmovimi, TO_NUMBER(pcindex(valores).valor_columna));
       --
    END LOOP;
    --
    RETURN 0;
  EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
  END f_setrechazo_icd10codes;

  /*************************************************************************
      Recupera la lista de evidencias medicas
      param out mensajes  : mensajes de error
      return              : cursor
   *************************************************************************/

    FUNCTION f_get_evidences(mensajes OUT t_iax_mensajes)
       RETURN sys_refcursor IS
       cur            sys_refcursor;
       vcidioma       NUMBER;
       vcempres       NUMBER;
       vpasexec       NUMBER(8) := 1;
       vparam         VARCHAR2(500) := ' ';
       vobject        VARCHAR2(200) := 'PAC_UNDERWRITING.f_get_evidences';
       vquery         VARCHAR2(2000);
    BEGIN
       vcempres := pac_md_common.f_get_cxtempresa();
       vcidioma := pac_md_common.f_get_cxtidioma();
       vquery := 'SELECT D.CEVIDEN, D.CODEVID, D.TEVIDEN, E.IEVIDEN, E.CTIPO '
                 || ' FROM DESEVIDENCIAS_UDW D, CODEVIDENCIAS_UDW E '
                 || ' WHERE D.CEVIDEN = E.CEVIDEN  ' || ' AND D.cidioma = ' || vcidioma || ' '
                 || ' AND D.cempres = ' || vcempres;
       cur := pac_md_listvalores.f_opencursor(vquery, mensajes);
       RETURN cur;
    EXCEPTION
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);

          IF cur%ISOPEN THEN
             CLOSE cur;
          END IF;

          RETURN cur;
    END f_get_evidences;

    FUNCTION f_insert_citasmedicas(
       psseguro IN NUMBER,
       pnriesgo IN NUMBER,
       pnmovimi IN NUMBER,
       psperaseg IN NUMBER,
       pspermed IN NUMBER,
       pceviden IN NUMBER,
       pfeviden IN DATE,
       pcestado IN NUMBER,
       ptablas IN VARCHAR2 DEFAULT 'EST',
       pieviden IN NUMBER,
       pcpago IN NUMBER,
       pnorden_r OUT NUMBER,
       pcais IN NUMBER,
       mensajes OUT t_iax_mensajes)
       RETURN NUMBER IS
       vpasexec       NUMBER(8) := 1;
       vparam         VARCHAR2(500)
          := ' psseguro=' || psseguro || ' pnriesgo=' || pnriesgo || ' pnmovimi=' || pnmovimi
             || ' psperaseg=' || psperaseg || ' pspermed=' || pspermed || ' pceviden=' || pceviden
             || ' pfeviden=' || pfeviden || ' pcestado=' || pcestado || ' ptablas=' || ptablas
             || ' pieviden=' || pieviden || ' pcpago=' || pcpago ||' pcais=' || pcais;
       vobject        VARCHAR2(200) := 'PAC_UNDERWRITING.f_insert_citasmedicas';
    BEGIN
       IF ptablas = 'EST' THEN
          vpasexec := 10;

          SELECT NVL(MAX(e.norden), 0) + 1
            INTO pnorden_r
            FROM estcitamedica_undw e
           WHERE e.sseguro = psseguro
             AND e.nriesgo = pnriesgo
             AND e.nmovimi = pnmovimi
             AND e.speraseg = psperaseg
             AND e.ceviden = pceviden;

          INSERT INTO estcitamedica_undw
                      (sseguro, nriesgo, nmovimi, speraseg, spermed, ceviden, norden,
                       feviden, cpago, cestado, ieviden, cusualt, falta, cais)
               VALUES (psseguro, NVL(pnriesgo,1), NVL(pnmovimi,(SELECT MAX(nmovimi)
                                     FROM estcitamedica_undw
                                    WHERE sseguro = psseguro
                                      AND nriesgo = pnriesgo
                                 )), psperaseg, pspermed, pceviden, pnorden_r,
                       pfeviden, pcpago, pcestado, pieviden, f_user, f_sysdate, pcais);

          vpasexec := 11;
       ELSE
          vpasexec := 20;

          SELECT NVL(MAX(norden), 0) + 1
            INTO pnorden_r
            FROM citamedica_undw
           WHERE sseguro = psseguro
             AND nriesgo = pnriesgo
             AND nmovimi = pnmovimi
             AND speraseg = psperaseg
             AND ceviden = pceviden;

          INSERT INTO citamedica_undw
                      (sseguro, nriesgo, nmovimi, speraseg, spermed, ceviden, norden,
                       feviden, cpago, cestado, ieviden, cusualt, falta, cais)
               VALUES (psseguro, pnriesgo, NVL(pnmovimi,(SELECT MAX(nmovimi)
                                     FROM estcitamedica_undw
                                    WHERE sseguro = psseguro
                                      AND nriesgo = pnriesgo
                                 )), psperaseg, pspermed, pceviden, pnorden_r,
                       pfeviden, pcpago, pcestado, pieviden, f_user, f_sysdate, pcais);

          vpasexec := 21;
       END IF;

       RETURN 0;
    EXCEPTION
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          RETURN 1;
    END f_insert_citasmedicas;


    FUNCTION f_edit_citasmedicas(
        psseguro IN NUMBER,
        pnriesgo IN NUMBER,
        pnmovimi IN NUMBER,
        psperaseg IN NUMBER,
        pspermed IN NUMBER,
        pceviden IN NUMBER,
        pfeviden IN DATE,
        pcestado IN NUMBER,
        ptablas IN VARCHAR2 DEFAULT 'EST',
        pieviden IN NUMBER,
        pcpago IN NUMBER,
        pnorden_r IN NUMBER,
        mensajes OUT t_iax_mensajes)
        RETURN NUMBER IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(500)
           := ' psseguro=' || psseguro || ' pnriesgo=' || pnriesgo || ' pnmovimi=' || pnmovimi
              || ' psperaseg=' || psperaseg || ' pspermed=' || pspermed || ' pceviden=' || pceviden
              || ' pfeviden=' || pfeviden || ' pcestado=' || pcestado || ' ptablas=' || ptablas
              || ' pieviden=' || pieviden || ' pcpago=' || pcpago || ' pnorden_r=' || pnorden_r;
        vobject        VARCHAR2(200) := 'PAC_UNDERWRITING.f_edit_citasmedicas';
        vnorden        NUMBER;
     BEGIN
        IF ptablas = 'EST' THEN
           vpasexec := 10;

           UPDATE estcitamedica_undw e
              SET e.feviden = pfeviden,
                  e.cestado = pcestado,
                  e.cpago = pcpago,
                  e.ieviden = pieviden,
                  e.spermed = pspermed
            WHERE e.sseguro = psseguro
              AND e.nriesgo = NVL(pnriesgo,1)
              AND e.nmovimi = NVL(pnmovimi,(SELECT MAX(nmovimi)
                                     FROM estcitamedica_undw
                                    WHERE sseguro = psseguro
                                      AND speraseg = psperaseg
                                      AND ceviden = pceviden
                                      AND norden = pnorden_r))
              AND e.speraseg = psperaseg
              AND e.ceviden = pceviden
              AND e.norden = pnorden_r;

           vpasexec := 11;
        ELSE
           vpasexec := 20;

           UPDATE citamedica_undw
              SET feviden = pfeviden,
                  cestado = pcestado,
                  cpago = pcpago,
                  ieviden = pieviden,
                  spermed = pspermed
            WHERE sseguro = psseguro
              AND nriesgo = NVL(pnriesgo,1)
              AND nmovimi = NVL(pnmovimi,(SELECT MAX(nmovimi)
                                   FROM citamedica_undw
                                  WHERE sseguro = psseguro
                                    AND speraseg = psperaseg
                                    AND ceviden = pceviden
                                    AND norden = pnorden_r))
              AND speraseg = psperaseg
              AND ceviden = pceviden
              AND norden = pnorden_r;

           vpasexec := 21;
        END IF;


        RETURN 0;
     EXCEPTION
        WHEN OTHERS THEN
           pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                             psqcode => SQLCODE, psqerrm => SQLERRM);
           RETURN 1;
    END f_edit_citasmedicas;

    FUNCTION f_delete_citasmedicas(
       psseguro IN NUMBER,
       pnriesgo IN NUMBER,
       pnmovimi IN NUMBER,
       psperaseg IN NUMBER,
       pceviden IN NUMBER,
       ptablas IN VARCHAR2 DEFAULT 'EST',
       pnorden_r IN NUMBER,
       mensajes OUT t_iax_mensajes)
       RETURN NUMBER IS
       vpasexec       NUMBER(8) := 1;
       vparam         VARCHAR2(500)
          := ' psseguro=' || psseguro || ' pnriesgo=' || pnriesgo || ' pnmovimi=' || pnmovimi
             || ' psperaseg=' || psperaseg || ' pceviden=' || pceviden || ' ptablas=' || ptablas
             || ' pnorden_r=' || pnorden_r;
       vobject        VARCHAR2(200) := 'PAC_UNDERWRITING.f_delete_citasmedicas';
       vnorden        NUMBER;
    BEGIN
       IF ptablas = 'EST' THEN
          vpasexec := 10;

          DELETE FROM estcitamedica_undw e
                WHERE e.sseguro = psseguro
                  AND e.nriesgo = pnriesgo
                  AND e.nmovimi = NVL(pnmovimi,(SELECT MAX(nmovimi)
                                   FROM citamedica_undw
                                  WHERE sseguro = psseguro
                                    AND speraseg = psperaseg
                                    AND ceviden = pceviden
                                    AND norden = pnorden_r))
                  AND e.speraseg = psperaseg
                  AND e.ceviden = pceviden
                  AND e.norden = pnorden_r;

          vpasexec := 11;
       ELSE
          vpasexec := 20;

          DELETE FROM citamedica_undw
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi = NVL(pnmovimi,(SELECT MAX(nmovimi)
                                   FROM citamedica_undw
                                  WHERE sseguro = psseguro
                                    AND speraseg = psperaseg
                                    AND ceviden = pceviden
                                    AND norden = pnorden_r))
                  AND speraseg = psperaseg
                  AND ceviden = pceviden
                  AND norden = pnorden_r;

          vpasexec := 21;
       END IF;

       RETURN 0;
    EXCEPTION
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          RETURN 1;
    END f_delete_citasmedicas;

   FUNCTION f_extract_loadings_if02(
      pcaseid    IN   NUMBER,
      pcempres   IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      psinterf   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
    ) RETURN NUMBER IS

      v_respuesta        CLOB;
      v_if02_xml         XMLTYPE;
      v_disclosures      XMLTYPE;
      v_case             XMLTYPE;
      v_acum_sum         NUMBER;
      v_acum_sum_l1         NUMBER;
      v_acum_sum_l2         NUMBER;
      v_valor_1908       NUMBER;
      v_valor_1909       NUMBER;
      v_valor_1984       NUMBER;
      v_valor_1985       NUMBER;
      v_valor_1912       NUMBER;
      v_valor_1913       NUMBER;
      v_valor_1914       NUMBER;
      v_valor_1915       NUMBER;
      v_valor_1921       NUMBER;--BUG 36596/212492
      v_valor_1922       NUMBER;-- BUG 36596/212492
      v_cadena_1926      VARCHAR2(32000);
      v_cadena_1927      VARCHAR2(32000);
      v_cgarant          int_codigos_emp.cvalaxis%TYPE;
      v_cgarant_premium  int_codigos_emp.cvalaxis%TYPE;
      v_cgarantload      int_codigos_emp.cvalaxis%TYPE;
      v_acum_sum_1        NUMBER := NULL;
      v_acum_sum_1_l1        NUMBER := NULL;
      v_acum_sum_1_l2        NUMBER := NULL;
      v_traza             NUMBER;
      v_dis1 NUMBER;
      v_dis2 NUMBER;
      v_adb1 NUMBER;
      v_adb2 NUMBER;
      v_asegurado VARCHAR2(1000);
      v_norden NUMBER;
      v_existe NUMBER;

      FUNCTION calcula_valor_pregunta(code VARCHAR2, base NUMBER)
        RETURN NUMBER IS
          v_encontro_rango   BOOLEAN;
          v_cont             NUMBER;
          v_rango_ini        NUMBER;
          v_valor            NUMBER := NULL;
          v_base             NUMBER;
      BEGIN
        v_base := nvl(base,0);
        IF code IN ('Lif', 'Dis', 'ADB') THEN
          v_encontro_rango := FALSE;
          v_cont := 1;
          v_rango_ini := 13;
          IF base <= 12 THEN
            v_valor := 0;
          ELSE
            v_encontro_rango := FALSE;
            v_cont := 1;
            v_rango_ini := 13;
            WHILE NOT v_encontro_rango LOOP
              IF (v_base >= v_rango_ini) AND (v_base <= (v_rango_ini+24)) THEN
                v_encontro_rango := TRUE;
                v_valor := 25*v_cont;
              ELSE
                v_rango_ini := v_rango_ini + 25;
                v_cont := v_cont + 1;
              END IF;
            END LOOP;
          END IF;
        ELSE
          v_valor := (v_base/100 + 1)*100;
        END IF;

        RETURN v_valor;
      END calcula_valor_pregunta;
   BEGIN
     v_traza := 1;
     SELECT xml_respuesta
       INTO v_respuesta
       FROM int_datos_xml
      WHERE sinterf = psinterf;

     v_traza := 2;
     IF v_respuesta IS NOT NULL THEN
        v_traza := 3;
        v_if02_xml := XMLTYPE.createxml(v_respuesta);
        v_case := v_if02_xml.EXTRACT('//case');

        v_traza := 4;
        FOR myCur0 IN (
          SELECT entitys."entity",entitys."tipo"
            FROM XMLTABLE('//underwriting/entity'
                 PASSING v_case
                 COLUMNS "entity" XMLTYPE PATH '/',
                         "tipo"   VARCHAR2(2000) PATH '@name'
                 ) entitys) LOOP

          v_traza := 5;

          v_acum_sum := NULL;
          v_acum_sum_l1 := 0;
          v_acum_sum_l2 := 0;
          v_valor_1908 := 0;
          v_valor_1909 := 0;
          v_valor_1912 := 0;
          v_valor_1913 := 0;
          v_valor_1914 := 0;
          v_valor_1915 := 0;
          v_valor_1984 := NULL;
          v_valor_1985 := NULL;
          v_cadena_1926 := NULL;
          v_cadena_1927 := NULL;
          v_valor_1921 := NULL;--
          v_valor_1922 := NULL;--

          FOR myCur01 IN (
            SELECT disclosures."condition",disclosures."id"
              FROM XMLTABLE('//disclosures/condition'
                   PASSING myCur0."entity"
                   COLUMNS "condition" XMLTYPE PATH '/',
                           "id"        VARCHAR2(2000) PATH '@id'
                   ) disclosures) LOOP

              v_traza := 6;

              FOR myCur1 IN (
                SELECT conditions."actions",conditions."name"
                  FROM XMLTABLE('//condition'
                       PASSING myCur01."condition"
                       COLUMNS "actions" XMLTYPE PATH '//actions',
                               "name"    VARCHAR2(2000) PATH '//name'
                       ) conditions) LOOP

                v_traza := 7;
                IF myCur1."actions" IS NOT NULL THEN
                  v_traza := 8;
                  v_cgarantload := null;
                  FOR myCur2 IN (
                     SELECT action."codegar",action."sumload"
                       FROM XMLTABLE('//action'
                            PASSING myCur1."actions"
                            COLUMNS "codegar"   VARCHAR2(2000) PATH '//riskType/@code',
                                    "sumload"   NUMBER PATH '//sumAssuredLoading'
                            ) action) LOOP

                     v_traza := 9;

                     IF myCur2."codegar" = 'Lif' THEN
                       IF myCur2."sumload" IS NOT NULL THEN
                         IF myCur0."tipo" = '1' THEN
                           v_acum_sum_l1 := NVL(v_acum_sum_l1,0) + myCur2."sumload";
                         ELSE
                           v_acum_sum_l2 := NVL(v_acum_sum_l2,0) + myCur2."sumload";
                         END IF;

                         v_traza := 10;
                         IF ptablas = 'EST' THEN
                            IF v_cgarantload IS NULL THEN
                               BEGIN
                                 select cvalaxis
                                   into v_cgarantload
                                   from int_codigos_emp i, estgaranseg g
                                  where cempres = pcempres
                                    AND cvalemp = myCur2."codegar"
                                    and g.sseguro = psseguro
                                    and g.nriesgo = pnriesgo
                                    AND g.nmovimi = pnmovimi
                                    and g.cgarant = i.cvalaxis
                                    AND EXISTS (SELECT 'X'
                                                  FROM estpregungaranseg eg
                                                 WHERE eg.sseguro = g.sseguro
                                                   AND eg.nriesgo = g.nriesgo
                                                   AND eg.nmovimi = g.nmovimi
                                                   AND eg.cgarant = g.cgarant );
                               EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                   v_cgarant := NULL;
                               END;
                            END IF;
                         ELSE
                           IF v_cgarantload IS NULL THEN
                              BEGIN
                                select cvalaxis
                                  into v_cgarantload
                                  from int_codigos_emp i, garanseg g
                                 where cempres = pcempres
                                   AND cvalemp = myCur2."codegar"
                                   and g.sseguro = psseguro
                                   and g.nriesgo = pnriesgo
                                   AND g.nmovimi = pnmovimi
                                   and g.cgarant = i.cvalaxis
                                   AND EXISTS (SELECT 'X'
                                                 FROM pregungaranseg eg
                                                WHERE eg.sseguro = g.sseguro
                                                  AND eg.nriesgo = g.nriesgo
                                                  AND eg.nmovimi = g.nmovimi
                                                  AND eg.cgarant = g.cgarant );
                              EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                  v_cgarant := NULL;
                              END;
                           END IF;
                         END IF;

                         v_traza := 11;
                         IF myCur1."name" IS NOT NULL THEN
                           IF myCur0."tipo" = '1' THEN
                             IF v_cadena_1926 IS NULL THEN
                               v_cadena_1926 := myCur1."name";
                             ELSE
                               v_cadena_1926 := v_cadena_1926||', '||myCur1."name";
                             END IF;
                           ELSE
                             IF v_cadena_1927 IS NULL THEN
                               v_cadena_1927 := myCur1."name";
                             ELSE
                               v_cadena_1927 := v_cadena_1927||', '||myCur1."name";
                             END IF;
                           END IF;
                         END IF;
                       END IF;
                     END IF;

                     IF myCur2."codegar" = 'ADB' THEN
                        IF myCur2."sumload" IS NOT NULL THEN
                          IF ptablas = 'EST' THEN

                            v_asegurado := NULL;

                            SELECT p.tnombre || ' ' || p.tapelli1 || ' ' || p.tapelli2
                            INTO v_asegurado
                            FROM estassegurats a, estper_detper p
                            WHERE a.sseguro = psseguro
                              AND a.sperson = p.sperson
                              AND a.norden = myCur0."tipo";

                            SELECT NVL(MAX(norden), 0) + 1
                            INTO v_norden
                            FROM ESTACTIONS_UNDW
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi = pnmovimi
                              AND cempres = pcempres
                              AND sorden = pcaseid;

                            SELECT COUNT(*)
                            INTO v_existe
                            FROM ESTACTIONS_UNDW
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi = pnmovimi
                              AND cempres = pcempres
                              AND sorden = pcaseid
                              AND naseg = myCur0."tipo"
                              AND action like '%Per mille decision case for ADB%';

                            IF v_existe = 0 THEN
                              INSERT INTO ESTACTIONS_UNDW
                                          (sseguro, nriesgo, nmovimi, cempres, sorden, norden, action, naseg)
                                   VALUES (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, v_norden, v_asegurado || ' - Per mille decision case for ADB', myCur0."tipo");
                            END IF;
                          ELSE
                            v_asegurado := NULL;

                            SELECT p.tnombre || ' ' || p.tapelli1 || ' ' || p.tapelli2
                            INTO v_asegurado
                            FROM asegurados a, per_detper p
                            WHERE a.sseguro = psseguro
                              AND a.sperson = p.sperson
                              AND a.norden = myCur0."tipo";

                            SELECT NVL(MAX(norden), 0) + 1
                            INTO v_norden
                            FROM ACTIONS_UNDW
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi = pnmovimi
                              AND cempres = pcempres
                              AND sorden = pcaseid;

                            SELECT COUNT(*)
                            INTO v_existe
                            FROM ACTIONS_UNDW
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi = pnmovimi
                              AND cempres = pcempres
                              AND sorden = pcaseid
                              AND naseg = myCur0."tipo"
                              AND action like '%Per mille decision case for ADB%';

                            IF v_existe = 0 THEN
                                INSERT INTO ACTIONS_UNDW
                                            (sseguro, nriesgo, nmovimi, cempres, sorden, norden, action, naseg)
                                     VALUES (psseguro, pnriesgo, pnmovimi, pcempres, pcaseid, v_norden, v_asegurado || ' - Per mille decision case for ADB', myCur0."tipo");
                            END IF;
                          END IF;
                        END IF;
                     END IF;
                  END LOOP;

                  v_traza := 12;

                   --BUG 36596/212492
                  -- Cursor para procesar los tag <termedSumAssuredLoading>--action."loadingTerm",action."termedSumAssuredLoading"
                  -- "termedSumAssuredLoading"   NUMBER PATH '//termedSumAssuredLoading',
                                    --"loadingTerm" VARCHAR2(2000) PATH '//loadingTerm'

                    FOR myCur4 IN (
                     SELECT action."codegar",action."termedSumAssuredLoading"
                       FROM XMLTABLE('//action'
                            PASSING myCur1."actions"
                            COLUMNS "codegar"   VARCHAR2(2000) PATH '//riskType/@code',
                                    "termedSumAssuredLoading"   NUMBER PATH '//termedSumAssuredLoading'
                            ) action) LOOP

                       v_traza := 13;
                       IF  myCur4."termedSumAssuredLoading" IS NOT NULL THEN
                               v_traza := 14;
                               IF myCur0."tipo" = '1' THEN
                                  v_acum_sum_1_l2 := NVL(v_acum_sum_1_l1,0) + myCur4."termedSumAssuredLoading";
                               ELSE
                                  v_acum_sum_1_l2 := NVL(v_acum_sum_1_l2,0) + myCur4."termedSumAssuredLoading";
                               END IF;

                               IF ptablas = 'EST' THEN
                                   BEGIN
                                     select cvalaxis
                                       into v_cgarant
                                       from int_codigos_emp i, estgaranseg g
                                      where cempres = pcempres
                                        AND cvalemp = myCur4."codegar"
                                        and g.sseguro = psseguro
                                        and g.nriesgo = pnriesgo
                                        AND g.nmovimi = pnmovimi
                                        and g.cgarant = i.cvalaxis
                                        AND EXISTS (SELECT 'X'
                                                      FROM estpregungaranseg eg
                                                     WHERE eg.sseguro = g.sseguro
                                                       AND eg.nriesgo = g.nriesgo
                                                       AND eg.nmovimi = g.nmovimi
                                                       AND eg.cgarant = g.cgarant );
                                   EXCEPTION
                                     WHEN NO_DATA_FOUND THEN
                                       v_cgarant := NULL;
                                   END;
                               ELSE
                                   BEGIN
                                     select cvalaxis
                                       into v_cgarant
                                       from int_codigos_emp i, garanseg g
                                      where cempres = pcempres
                                        AND cvalemp = myCur4."codegar"
                                        and g.sseguro = psseguro
                                        and g.nriesgo = pnriesgo
                                        AND g.nmovimi = pnmovimi
                                        and g.cgarant = i.cvalaxis
                                        AND EXISTS (SELECT 'X'
                                                      FROM pregungaranseg eg
                                                     WHERE eg.sseguro = g.sseguro
                                                       AND eg.nriesgo = g.nriesgo
                                                       AND eg.nmovimi = g.nmovimi
                                                       AND eg.cgarant = g.cgarant );
                                   EXCEPTION
                                     WHEN NO_DATA_FOUND THEN
                                       v_cgarant := NULL;
                                   END;
                               END IF;
                       END IF;
                  END LOOP;

                  v_traza := 15;
                  IF myCur0."tipo" = '1' THEN
                    v_valor_1921:= v_acum_sum_1_l1;
                  ELSE
                    v_valor_1922:= v_acum_sum_1_l2;
                  END IF;
                  -- FIN 36596/212492


                  -- Cursor para procesar los tag <premiumLoading>
                  FOR myCur3 IN (
                     SELECT action."codegar",action."premium"
                       FROM XMLTABLE('//action'
                            PASSING myCur1."actions"
                            COLUMNS "codegar"   VARCHAR2(2000) PATH '//riskType/@code',
                                    "premium"   NUMBER PATH '//premiumLoading'
                            ) action) LOOP
                     v_traza := 16;
                     IF myCur3."premium"  IS NOT NULL THEN
                       IF ptablas = 'EST' THEN
                           BEGIN
                             select cvalaxis
                               into v_cgarant_premium
                               from int_codigos_emp i, estgaranseg g
                              where cempres = pcempres
                                AND cvalemp = myCur3."codegar"
                                and g.sseguro = psseguro
                                and g.nriesgo = pnriesgo
                                AND g.nmovimi = pnmovimi
                                and g.cgarant = i.cvalaxis
                                AND EXISTS (SELECT 'X'
                                              FROM estpregungaranseg eg
                                             WHERE eg.sseguro = g.sseguro
                                               AND eg.nriesgo = g.nriesgo
                                               AND eg.nmovimi = g.nmovimi
                                               AND eg.cgarant = g.cgarant );
                           EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                               v_cgarant_premium := NULL;
                           END;
                       ELSE
                           BEGIN
                             select cvalaxis
                               into v_cgarant_premium
                               from int_codigos_emp i, garanseg g
                              where cempres = pcempres
                                AND cvalemp = myCur3."codegar"
                                and g.sseguro = psseguro
                                and g.nriesgo = pnriesgo
                                AND g.nmovimi = pnmovimi
                                and g.cgarant = i.cvalaxis
                                AND EXISTS (SELECT 'X'
                                              FROM pregungaranseg eg
                                             WHERE eg.sseguro = g.sseguro
                                               AND eg.nriesgo = g.nriesgo
                                               AND eg.nmovimi = g.nmovimi
                                               AND eg.cgarant = g.cgarant );
                           EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                               v_cgarant_premium := NULL;
                           END;
                       END IF;

                       v_traza := 17;
                       IF v_cgarant_premium IS NOT NULL THEN
                         v_traza := 18;
                         IF ptablas = 'EST' THEN
                            IF myCur3."codegar" IN ('Lif', 'CCI') THEN
                              IF myCur0."tipo" = '1' THEN
                                v_valor_1908 := v_valor_1908 + calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                UPDATE estpregungaranseg
                                   SET crespue = v_valor_1908
                                 WHERE sseguro = psseguro
                                   AND nriesgo = pnriesgo
                                   AND nmovimi = pnmovimi
                                   AND cgarant = v_cgarant_premium
                                   AND cpregun = 1908;
                              ELSE
                                v_valor_1909 := v_valor_1909 + calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                UPDATE estpregungaranseg
                                   SET crespue = v_valor_1909
                                 WHERE sseguro = psseguro
                                   AND nriesgo = pnriesgo
                                   AND nmovimi = pnmovimi
                                   AND cgarant = v_cgarant_premium
                                   AND cpregun = 1909;
                              END IF;
                            ELSIF myCur3."codegar" = 'Dis' THEN
                              IF myCur0."tipo" = '1' THEN

                                v_valor_1914 := v_valor_1914 + myCur3."premium"; --calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                v_dis1 := 1;
                              ELSE
                                v_valor_1915 := v_valor_1915 + myCur3."premium"; --calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                v_dis2 := 1;
                              END IF;
                            ELSIF myCur3."codegar" = 'ADB' THEN
                              IF myCur0."tipo" = '1' THEN
                                v_valor_1912 := v_valor_1912 + myCur3."premium"; --calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                v_adb1 := 1;
                              ELSE
                                v_valor_1913 := v_valor_1913 + myCur3."premium"; --calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                v_adb2 := 1;
                              END IF;
                            END IF;
                         ELSE
                            IF myCur3."codegar" IN ('Lif', 'CCI') THEN
                              IF myCur0."tipo" = '1' THEN
                                v_valor_1908 := v_valor_1908 + calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                UPDATE pregungaranseg
                                   SET crespue = v_valor_1908
                                 WHERE sseguro = psseguro
                                   AND nriesgo = pnriesgo
                                   AND nmovimi = pnmovimi
                                   AND cgarant = v_cgarant_premium
                                   AND cpregun = 1908;
                              ELSE
                                v_valor_1909 := v_valor_1909 + calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                UPDATE pregungaranseg
                                   SET crespue = v_valor_1909
                                 WHERE sseguro = psseguro
                                   AND nriesgo = pnriesgo
                                   AND nmovimi = pnmovimi
                                   AND cgarant = v_cgarant_premium
                                   AND cpregun = 1909;
                              END IF;
                            ELSIF myCur3."codegar" = 'Dis' THEN
                              IF myCur0."tipo" = '1' THEN
                                v_valor_1914 := v_valor_1914 + myCur3."premium"; --calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                v_dis1 := 1;
                              ELSE
                                v_valor_1915 := v_valor_1915 + myCur3."premium"; --calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                v_dis2 := 1;
                              END IF;
                            ELSIF myCur3."codegar" = 'ADB' THEN
                              IF myCur0."tipo" = '1' THEN
                                v_valor_1912 := v_valor_1912 + myCur3."premium"; --calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                v_adb1 := 1;
                              ELSE
                                v_valor_1913 := v_valor_1913 + myCur3."premium"; --calcula_valor_pregunta(myCur3."codegar",myCur3."premium");
                                v_adb2 := 1;
                              END IF;
                            END IF;
                         END IF;
                       END IF;
                       v_traza := 19;

                       IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
                           AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
                           FOR j IN
                              pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
                              IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias IS NOT NULL
                                 AND pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias.COUNT > 0 THEN
                                    FOR z IN pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias.LAST LOOP
                                        IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas IS NOT NULL
                                           AND pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas.COUNT > 0 THEN
                                            FOR y IN
                                                pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas.LAST LOOP

                                                IF myCur3."codegar" IN ('Lif', 'CCI') THEN
                                                   IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1908 AND myCur0."tipo" = '1' THEN
                                                     pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := v_valor_1908;
                                                   END IF;

                                                   IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1909 AND myCur0."tipo" = '2' THEN
                                                     pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := v_valor_1909;
                                                   END IF;
                                                END IF;
                                            END LOOP;
                                        END IF;
                                    END LOOP;
                              END IF;
                           END LOOP;
                       END IF;

                     END IF;
                  END LOOP;  -- Fin cursor myCur3 - tag <premiumLoading>
                END IF; -- Existen tags <actions>
              END LOOP; -- Fin cursor myCur1 - tag <actions>
          END LOOP; -- Fin cursor myCur01 - tag <condition>

          IF v_dis1 = 1 THEN
                   BEGIN
                     select cvalaxis
                       into v_cgarant_premium
                       from int_codigos_emp i, estgaranseg g
                      where cempres = pcempres
                        AND cvalemp = 'Dis'
                        and g.sseguro = psseguro
                        and g.nriesgo = pnriesgo
                        AND g.nmovimi = pnmovimi
                        and g.cgarant = i.cvalaxis
                        AND EXISTS (SELECT 'X'
                                      FROM estpregungaranseg eg
                                     WHERE eg.sseguro = g.sseguro
                                       AND eg.nriesgo = g.nriesgo
                                       AND eg.nmovimi = g.nmovimi
                                       AND eg.cgarant = g.cgarant );
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       v_cgarant_premium := NULL;
                   END;

                        v_valor_1914 := calcula_valor_pregunta('Dis',v_valor_1914);

                        UPDATE estpregungaranseg
                           SET crespue = v_valor_1914
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND nmovimi = pnmovimi
                           AND cgarant = v_cgarant_premium
                           AND cpregun = 1914;
          END IF;

          IF v_dis2 = 1 THEN
                   BEGIN
                     select cvalaxis
                       into v_cgarant_premium
                       from int_codigos_emp i, estgaranseg g
                      where cempres = pcempres
                        AND cvalemp = 'Dis'
                        and g.sseguro = psseguro
                        and g.nriesgo = pnriesgo
                        AND g.nmovimi = pnmovimi
                        and g.cgarant = i.cvalaxis
                        AND EXISTS (SELECT 'X'
                                      FROM estpregungaranseg eg
                                     WHERE eg.sseguro = g.sseguro
                                       AND eg.nriesgo = g.nriesgo
                                       AND eg.nmovimi = g.nmovimi
                                       AND eg.cgarant = g.cgarant );
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       v_cgarant_premium := NULL;
                   END;

                        v_valor_1915 := calcula_valor_pregunta('Dis',v_valor_1915);

                        UPDATE estpregungaranseg
                           SET crespue = v_valor_1915
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND nmovimi = pnmovimi
                           AND cgarant = v_cgarant_premium
                           AND cpregun = 1915;
          END IF;

          IF v_adb1 = 1 THEN
                   BEGIN
                     select cvalaxis
                       into v_cgarant_premium
                       from int_codigos_emp i, estgaranseg g
                      where cempres = pcempres
                        AND cvalemp = 'ADB'
                        and g.sseguro = psseguro
                        and g.nriesgo = pnriesgo
                        AND g.nmovimi = pnmovimi
                        and g.cgarant = i.cvalaxis
                        AND EXISTS (SELECT 'X'
                                      FROM estpregungaranseg eg
                                     WHERE eg.sseguro = g.sseguro
                                       AND eg.nriesgo = g.nriesgo
                                       AND eg.nmovimi = g.nmovimi
                                       AND eg.cgarant = g.cgarant );
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       v_cgarant_premium := NULL;
                   END;

                        v_valor_1912 := calcula_valor_pregunta('ADB',v_valor_1912);

                        UPDATE estpregungaranseg
                           SET crespue = v_valor_1912
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND nmovimi = pnmovimi
                           AND cgarant = v_cgarant_premium
                           AND cpregun = 1912;
          END IF;

          IF v_adb2 = 1 THEN
                   BEGIN
                     select cvalaxis
                       into v_cgarant_premium
                       from int_codigos_emp i, estgaranseg g
                      where cempres = pcempres
                        AND cvalemp = 'ADB'
                        and g.sseguro = psseguro
                        and g.nriesgo = pnriesgo
                        AND g.nmovimi = pnmovimi
                        and g.cgarant = i.cvalaxis
                        AND EXISTS (SELECT 'X'
                                      FROM estpregungaranseg eg
                                     WHERE eg.sseguro = g.sseguro
                                       AND eg.nriesgo = g.nriesgo
                                       AND eg.nmovimi = g.nmovimi
                                       AND eg.cgarant = g.cgarant );
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       v_cgarant_premium := NULL;
                   END;

                        v_valor_1913 := calcula_valor_pregunta('ADB',v_valor_1913);

                        UPDATE estpregungaranseg
                           SET crespue = v_valor_1913
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND nmovimi = pnmovimi
                           AND cgarant = v_cgarant_premium
                           AND cpregun = 1913;
          END IF;

         IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
             AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
             FOR j IN
                pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
                IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias IS NOT NULL
                   AND pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias.COUNT > 0 THEN
                      FOR z IN pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias.LAST LOOP
                          IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas IS NOT NULL
                             AND pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas.COUNT > 0 THEN
                              FOR y IN
                                  pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas.LAST LOOP

                                  IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).cgarant IN (1943, 1903) THEN
                                     IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1914 AND myCur0."tipo" = '1' THEN
                                       IF v_valor_1914 <> 0 THEN
                                          pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := v_valor_1914;
                                       ELSE
                                          pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := 0;
                                       END IF;
                                     END IF;

                                     IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1915 AND myCur0."tipo" = '2' THEN
                                       IF v_valor_1915 <> 0 THEN
                                       pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := v_valor_1915;
                                       ELSE
                                          pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := 0;
                                       END IF;
                                     END IF;
                                  ELSIF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).cgarant IN (1902) THEN
                                     IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1912 AND myCur0."tipo" = '1' THEN
                                       IF v_valor_1912 <> 0 THEN
                                         pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := v_valor_1912;
                                       ELSE
                                          pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := 0;
                                       END IF;
                                     END IF;

                                     IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1913 AND myCur0."tipo" = '2' THEN
                                       IF v_valor_1913 <> 0 THEN
                                          pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := v_valor_1913;
                                       ELSE
                                          pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := 0;
                                       END IF;
                                     END IF;
                                  END IF;
                              END LOOP;
                          END IF;
                      END LOOP;
                END IF;
             END LOOP;
         END IF;


          v_traza := 20;


          IF myCur0."tipo" = '1' THEN
            v_valor_1984 := v_acum_sum_l1;
          ELSE
            v_valor_1985 := v_acum_sum_l2;
          END IF;

          --BUG 36596/212492
          IF v_cgarant IS NOT NULL THEN
            v_traza := 21;
            IF ptablas = 'EST' THEN
               IF v_valor_1921 IS NOT NULL THEN
                 UPDATE estpregungaranseg
                    SET crespue = v_valor_1921
                  WHERE sseguro = psseguro
                    AND nriesgo = pnriesgo
                    AND nmovimi = pnmovimi
                    AND cgarant = v_cgarant
                    AND cpregun = 1921;
               END IF;

               IF v_valor_1922 IS NOT NULL THEN
                 UPDATE estpregungaranseg
                    SET crespue = v_valor_1922
                  WHERE sseguro = psseguro
                    AND nriesgo = pnriesgo
                    AND nmovimi = pnmovimi
                    AND cgarant = v_cgarant
                    AND cpregun = 1922;
               END IF;
            ELSE
               IF v_valor_1921 IS NOT NULL THEN
                 UPDATE pregungaranseg
                    SET crespue = v_valor_1921
                  WHERE sseguro = psseguro
                    AND nriesgo = pnriesgo
                    AND nmovimi = pnmovimi
                    AND cgarant = v_cgarant
                    AND cpregun = 1921;
               END IF;

               IF v_valor_1922 IS NOT NULL THEN
                 UPDATE pregungaranseg
                    SET crespue = v_valor_1922
                  WHERE sseguro = psseguro
                    AND nriesgo = pnriesgo
                    AND nmovimi = pnmovimi
                    AND cgarant = v_cgarant
                    AND cpregun = 1922;
               END IF;
            END IF;
          END IF;
          -- FIN 36596/212492
          v_traza := 22;
          IF v_cgarantload IS NOT NULL THEN
            v_traza := 23;
            IF ptablas = 'EST' THEN
              IF v_valor_1984 IS NOT NULL THEN
                UPDATE estpregungaranseg
                   SET crespue = v_valor_1984
                 WHERE sseguro = psseguro
                   AND nriesgo = pnriesgo
                   AND nmovimi = pnmovimi
                   AND cgarant = v_cgarantload
                   AND cpregun = 1984;
              END IF;

              IF v_valor_1985 IS NOT NULL THEN
                UPDATE estpregungaranseg
                   SET crespue = v_valor_1985
                 WHERE sseguro = psseguro
                   AND nriesgo = pnriesgo
                   AND nmovimi = pnmovimi
                   AND cgarant = v_cgarantload
                   AND cpregun = 1985;
              END IF;

              IF v_cadena_1926 IS NOT NULL THEN
                UPDATE estpregungaranseg
                   SET trespue = v_cadena_1926
                 WHERE sseguro = psseguro
                   AND nriesgo = pnriesgo
                   AND nmovimi = pnmovimi
                   AND cgarant = v_cgarantload
                   AND cpregun = 1926;
              END IF;

              IF v_cadena_1927 IS NOT NULL THEN
                UPDATE estpregungaranseg
                   SET trespue = v_cadena_1927
                 WHERE sseguro = psseguro
                   AND nriesgo = pnriesgo
                   AND nmovimi = pnmovimi
                   AND cgarant = v_cgarantload
                   AND cpregun = 1927;
              END IF;
            ELSE
              IF v_valor_1984 IS NOT NULL THEN
                UPDATE pregungaranseg
                   SET crespue = v_valor_1984
                 WHERE sseguro = psseguro
                   AND nriesgo = pnriesgo
                   AND nmovimi = pnmovimi
                   AND cgarant = v_cgarantload
                   AND cpregun = 1984;
              END IF;

              IF v_valor_1985 IS NOT NULL THEN
                UPDATE pregungaranseg
                   SET crespue = v_valor_1985
                 WHERE sseguro = psseguro
                   AND nriesgo = pnriesgo
                   AND nmovimi = pnmovimi
                   AND cgarant = v_cgarantload
                   AND cpregun = 1985;
              END IF;

              IF v_cadena_1926 IS NOT NULL THEN
                UPDATE pregungaranseg
                   SET trespue = v_cadena_1926
                 WHERE sseguro = psseguro
                   AND nriesgo = pnriesgo
                   AND nmovimi = pnmovimi
                   AND cgarant = v_cgarantload
                   AND cpregun = 1926;
              END IF;

              IF v_cadena_1927 IS NOT NULL THEN
                UPDATE pregungaranseg
                   SET trespue = v_cadena_1927
                 WHERE sseguro = psseguro
                   AND nriesgo = pnriesgo
                   AND nmovimi = pnmovimi
                   AND cgarant = v_cgarantload
                   AND cpregun = 1927;
              END IF;
            END IF;
          END IF;
          v_traza := 24;


          IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
             AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
             FOR j IN
                pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
                IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias IS NOT NULL
                   AND pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias.COUNT > 0 THEN
                      FOR z IN pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias.LAST LOOP
                          IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas IS NOT NULL
                             AND pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas.COUNT > 0 THEN
                              FOR y IN
                                  pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas.LAST LOOP

                                  IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1984 AND v_valor_1984 IS NOT NULL THEN
                                    pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := v_valor_1984;
                                  END IF;

                                  IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1985 AND v_valor_1985 IS NOT NULL THEN
                                    pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := v_valor_1985;
                                  END IF;

                                  IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1926 AND v_cadena_1926 IS NOT NULL THEN
                                    pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).trespue := v_cadena_1926;
                                  END IF;

                                  IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1927 AND v_cadena_1927 IS NOT NULL THEN
                                    pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).trespue := v_cadena_1927;
                                  END IF;
                                                                    --BUG 36596/212492
                                   IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1921 AND v_valor_1921 IS NOT NULL THEN
                                    pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := v_valor_1921;
                                  END IF;

                                  IF pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).cpregun = 1922 AND v_valor_1922 IS NOT NULL THEN
                                    pac_iax_produccion.poliza.det_poliza.riesgos(j).garantias(z).preguntas(y).crespue := v_valor_1922;
                                  END IF;
                                  -- FIN 36596/212492
                              END LOOP;
                          END IF;
                      END LOOP;
                END IF;
             END LOOP;
          END IF;
          v_traza := 25;
        END LOOP;
        v_traza := 26;
     END IF;
        v_traza := 27;
     RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_extract_loadings_if02', v_traza,
                     'pcempres=' || pcempres || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pnmovimi = ' || pnmovimi
                     || ' ptablas = ' || ptablas,
                     SQLERRM);
         RETURN 1;
   END f_extract_loadings_if02;

   FUNCTION f_get_attributesum_insured(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN XMLTYPE IS
      v_edad         pregunseg.crespue%TYPE;
      v_res          NUMBER;
      v_attribute    XMLTYPE;
      v_suminsured   NUMBER;
      v_banda        NUMBER;
      v_sproduc      NUMBER;
      v_aux          NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN

         SELECT sproduc
         INTO   v_sproduc
         FROM   estseguros
          WHERE sseguro = psseguro;

         IF v_sproduc = 1904 THEN
             v_aux := pac_preguntas.f_get_pregunseg(
                                    psseguro,
                                    pnriesgo,
                                    1940,
                                    'EST',
                                    v_suminsured);

         ELSE
            SELECT icapital
            INTO v_suminsured
            FROM estgaranseg e, estseguros s, garanpro g
            WHERE e.sseguro = psseguro
              AND e.nmovimi = pnmovimi
              AND e.cobliga = 1
              AND e.sseguro = s.sseguro
              AND s.sproduc = g.sproduc
              AND e.cgarant = g.cgarant
              AND g.cbasica = 1;
         END IF;
      ELSE
        SELECT icapital
        INTO v_suminsured
        FROM garanseg e, seguros s, garanpro g
        WHERE e.sseguro = psseguro
          AND e.nmovimi = pnmovimi
          AND e.sseguro = s.sseguro
          AND s.sproduc = g.sproduc
          AND e.cgarant = g.cgarant
          AND g.cbasica = 1;
      END IF;

      IF v_suminsured <= 100000 THEN
          v_banda := 1;
      ELSIF v_suminsured <= 200000 THEN
          v_banda := 2;
      ELSIF v_suminsured <= 250000 THEN
          v_banda := 3;
      ELSIF v_suminsured <= 350000 THEN
          v_banda := 4;
      ELSIF v_suminsured <= 500000 THEN
          v_banda := 5;
      ELSIF v_suminsured <= 750000 THEN
          v_banda := 6;
      ELSIF v_suminsured <= 825000 THEN
          v_banda := 7;
      ELSIF v_suminsured <= 2000000 THEN
          v_banda := 8;
      ELSE
          v_banda := 9;
      END IF;

      SELECT XMLELEMENT("attribute", xmlattributes('SUM_INSURED_BAND' AS "name", v_banda AS "value"))
        INTO v_attribute
        FROM DUAL;

      RETURN v_attribute;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_UNDERWRITING.f_get_attributesum_insured', 1,
                     'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' ptablas = '
                     || ptablas,
                     SQLERRM);
         RETURN NULL;
   END f_get_attributesum_insured;

   FUNCTION f_initializes_appointments(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      -- 37574/213761 IGIL INI
      pnmovimi IN NUMBER,
      -- 37574/213761 IGIL FIN
      pcodevi IN VARCHAR,
      pentity IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR(100) := 'PAC_UNDERWRITING.f_initializes_appointments';
      v_params       VARCHAR(1000)
         := 'psseguro=' || psseguro || ' pnriesgo = ' || pnriesgo || ' pcodevi = ' || pcodevi
            || ' pentity = ' || pentity;
      v_pasexc       NUMBER := 0;
      v_numerr NUMBER := 0;
      mensajes t_iax_mensajes;
      vcontacita NUMBER;

      CURSOR c_evidencias IS
         SELECT (SELECT MAX(nmovimi)
                   FROM estcitamedica_undw
                  WHERE sseguro = psseguro
                    AND nriesgo = pnriesgo) v_nmovimi, a.sperson,
                (SELECT per1.nnumide ||' - '|| per.tnombre
                   FROM estper_detper per, estper_personas per1
                  WHERE per1.sperson = a.sperson
                    AND per1.sperson = per.sperson) v_nomaseg, evi.ceviden, evi.teviden, evi.codevid,
                cev.ieviden,
                (SELECT NVL(MAX(norden), 0) + 1
                   FROM estcitamedica_undw
                  WHERE sseguro = psseguro
                    AND nriesgo = pnriesgo
                    AND speraseg = a.sperson
                    AND ceviden = evi.ceviden) norden,
                det.catribu v_cestado, det.tatribu v_testado, f_user, f_sysdate, cev.ctipo
           FROM estassegurats a, desevidencias_udw evi, codevidencias_udw cev, detvalores det
          WHERE evi.codevid = pcodevi
            AND evi.ceviden = cev.ceviden
            AND a.sseguro = psseguro
            AND a.norden = pentity
            AND evi.cidioma = pac_md_common.f_get_cxtidioma
            AND det.cvalor = 8001025
            AND det.cidioma = evi.cidioma
            AND det.catribu = 1;
   BEGIN
      v_pasexc := 1;

      FOR eviden IN c_evidencias LOOP

         SELECT count(*)
         INTO vcontacita
         FROM estcitamedica_undw
         WHERE sseguro = psseguro
           AND nriesgo = pnriesgo
           and nmovimi = NVL(pnmovimi, eviden.v_nmovimi)
           and ceviden = eviden.ceviden
           and speraseg = eviden.sperson -- Para el asegurado en cuestión.
           AND cais = 1;

        IF vcontacita = 0 THEN
           v_pasexc := 2;
                 -- 37574/213761 IGIL INI
           v_numerr := pac_iax_produccion.f_insert_citasmedicas(psseguro, pnriesgo, NVL(pnmovimi,eviden.v_nmovimi),
                 -- 37574/213761 IGIL INI
                                                    eviden.v_nomaseg, eviden.sperson, NULL, NULL,
                                                    eviden.ceviden, eviden.teviden, eviden.codevid,
                                                    NULL, eviden.v_cestado, eviden.v_testado,
                                                    eviden.ieviden, 0, eviden.ctipo,1, mensajes);
           v_pasexc := 3;
        END IF;
      END LOOP;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexc, v_params, SQLERRM);
         RETURN 1;
   END f_initializes_appointments;
END pac_underwriting;

/

  GRANT EXECUTE ON "AXIS"."PAC_UNDERWRITING" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_UNDERWRITING" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_UNDERWRITING" TO "PROGRAMADORESCSI";
