--------------------------------------------------------
--  DDL for Package Body PAC_WIZARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_WIZARD" 
IS
   FUNCTION f_consupl_form (
      pcconsupl   IN   VARCHAR2,
      ptform      IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      resultado   NUMBER;
   BEGIN
      /*
      {función que nos retorna un 1 si una configuración utiliza un form}
      */
      SELECT COUNT (1)
      INTO   resultado
      FROM   pds_supl_cod_config cc, pds_supl_form f
      WHERE  cc.cconsupl = pcconsupl
      AND    cc.cconfig = f.cconfig
      AND    f.tform = ptform;

      IF resultado > 1 THEN
         resultado    := 1;
      END IF;

      RETURN resultado;
   END;

------------------------------------------------
   FUNCTION f_codwizard (
      puser        IN       VARCHAR2,
      pform        IN       VARCHAR2,
      psproduc     IN       NUMBER,
      pcmodo                VARCHAR2,
      pform_sig    IN OUT   VARCHAR2,
      pform_ant    IN OUT   VARCHAR2,
      pniteracio   IN OUT   NUMBER,
      pcsituac     IN OUT   VARCHAR2,
      pccamptf     IN       VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
/*
{Función que nos devuelve con parametros de salida que formulario es el siguiente ,
 anterior, cuantas iteraciones permite el form actual y su posición (csituac)
 F.-FINAL,P.- PRIMER, O.-OTRAS}
*/
      c_cconfwiz   VARCHAR2 (50);
   BEGIN
      /*
      {Primero se mira que configuración tiene el usuario asignada}
      */
      BEGIN
         SELECT cconfwiz
         INTO   c_cconfwiz
         FROM   pds_config_user
         WHERE  cuser = UPPER (puser);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 151746;
      --{No se ha encontrado la configuración de navegación para este usuario}
      END;

      IF c_cconfwiz IS NULL THEN
         RETURN 151746;
      --{No se ha encontrado la configuración de navegación para este usuario}
      END IF;

      BEGIN
         SELECT form_ant,
                form_sig,
                csituac,
                niteracio
         INTO   pform_ant,
                pform_sig,
                pcsituac,
                pniteracio
         FROM   pds_config_wizard
         WHERE  cconfwiz = c_cconfwiz
         AND    form_act = pform
         AND    sproduc = psproduc
         AND    cmodo = pcmodo
         AND    campo_act = DECODE (NVL (pccamptf, '0'), '0', '*', pccamptf);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF psproduc IS NULL THEN
               -- Agafem un formulari sense tenir en compte el producte
               BEGIN
                  SELECT MIN (form_ant),
                         MIN (form_sig),
                         MIN (csituac),
                         MIN (niteracio)
                  INTO   pform_ant,
                         pform_sig,
                         pcsituac,
                         pniteracio
                  FROM   pds_config_wizard
                  WHERE  cconfwiz = c_cconfwiz
                  AND    form_act = pform
                  AND    cmodo = pcmodo
                  AND    campo_act =
                              DECODE (NVL (pccamptf, '0'),
                                      '0', '*',
                                      pccamptf
                                     );
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 151085;
               END;
            ELSE
               RETURN 151085;
            END IF;
         WHEN OTHERS THEN
            RETURN 151085;
      END;

      IF pcsituac = 'P' THEN                 -- Si es el primer no té anterior
         pform_ant    := NULL;
      ELSIF pcsituac = 'F' THEN         -- Si es el ultimo no tiene siguiente.
         pform_sig    := NULL;
      END IF;

      RETURN 0;
   END f_codwizard;

   FUNCTION f_codwizard_ini (
      puser      IN       VARCHAR2,
      psproduc   IN       NUMBER,
      pcmodo              VARCHAR2,
      pform      IN OUT   VARCHAR2
   )
      RETURN NUMBER
   IS
      /*
      {F_CodWizard_Ini: función que nos devuelve el formulario con el cual se
       empezará la ejecución de Wizard}
      */
      c_cconfwiz   VARCHAR2 (50);
   BEGIN
      /*
      {Primero se mira que configuración tiene el usuario asignada}
      */
      BEGIN
         SELECT cconfwiz
         INTO   c_cconfwiz
         FROM   pds_config_user
         WHERE  cuser = UPPER (puser);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 151746;
      --{No se ha encontrado la configuración de navegación para este usuario}
      END;

      IF c_cconfwiz IS NULL THEN
         RETURN 151746;
      --{No se ha encontrado la configuración de navegación para este usuario}
      END IF;

      BEGIN
         SELECT form_act
         INTO   pform
         FROM   pds_config_wizard
         WHERE  cconfwiz = c_cconfwiz
         AND    csituac = 'P'
         AND    sproduc = psproduc
         AND    cmodo = pcmodo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF psproduc IS NULL THEN
               -- Agafem un formulari sense tenir en compte el producte
               BEGIN
                  SELECT MIN (form_act)
                  INTO   pform
                  FROM   pds_config_wizard
                  WHERE  cconfwiz = c_cconfwiz
                  AND    csituac = 'P'
                  AND    cmodo = pcmodo;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 151085;
               END;
            ELSE
               RETURN 151085;
            END IF;
         WHEN OTHERS THEN
            RETURN 151085;
      END;

      RETURN 0;
   END f_codwizard_ini;

   FUNCTION f_obtener_from (
      pcuser     IN   VARCHAR2,
      psproduc   IN   NUMBER,
      pmodo      IN   VARCHAR2,
      pform      IN   VARCHAR2,
      pccamptf   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      v_vform      VARCHAR2 (50);
      c_cconfwiz   VARCHAR2 (50);
      c_cconsupl   VARCHAR2 (50);
   BEGIN
      /*
      {Primero se mira que configuración tiene el usuario asignada}
      */
      BEGIN
         SELECT cconfwiz
         INTO   c_cconfwiz
         FROM   pds_config_user
         WHERE  cuser = UPPER (pcuser);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 151746;
      --{No se ha encontrado la configuración de navegación para este usuario}
      END;

      IF c_cconfwiz IS NULL THEN
         RETURN 151746;
      --{No se ha encontrado la configuración de navegación para este usuario}
      END IF;

        /*
       {Buscamos los forms de destino, primero  los que conincidan con el campo
      , despues con el bloque, y finalmente con el formulario}
       */
      BEGIN
         SELECT DISTINCT form_sig
         INTO            v_vform
         FROM            pds_config_wizard
         WHERE           cconfwiz = c_cconfwiz
         AND             form_act = pform
         AND             sproduc = psproduc
         AND             cmodo = pmodo
         AND             campo_act = pccamptf;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT DISTINCT form_sig
               INTO            v_vform
               FROM            pds_config_wizard
               WHERE           cconfwiz = c_cconfwiz
               AND             form_act = pform
               AND             sproduc = psproduc
               AND             cmodo = pmodo
               AND             campo_act =
                                  SUBSTR (pccamptf,
                                          0,
                                          INSTR (pccamptf, '.') - 1
                                         );
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT DISTINCT form_sig
                     INTO            v_vform
                     FROM            pds_config_wizard
                     WHERE           cconfwiz = c_cconfwiz
                     AND             form_act = pform
                     AND             sproduc = psproduc
                     AND             cmodo = pmodo
                     AND             campo_act = '*';
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_vform    := NULL;
                  END;
            END;
      END;

      RETURN v_vform;
   END;

   FUNCTION f_obtener_nsuplem (
      pcuser     IN   VARCHAR2,
      psproduc   IN   NUMBER,
      pmodo      IN   VARCHAR2,
      pform      IN   VARCHAR2,
      pccamptf   IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      total        NUMBER;
      c_cconfwiz   VARCHAR2 (50);
      c_cconsupl   VARCHAR2 (50);
   BEGIN
      /*
         {Primero se mira que configuración tiene el usuario asignada}
         */
      BEGIN
         SELECT cconfwiz,
                cconsupl
         INTO   c_cconfwiz,
                c_cconsupl
         FROM   pds_config_user
         WHERE  cuser = UPPER (pcuser);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 151746;
      --{No se ha encontrado la configuración de navegación para este usuario}
      END;

      IF    c_cconfwiz IS NULL
         OR c_cconsupl IS NULL THEN
         RETURN 151746;
      --{No se ha encontrado la configuración de navegación para este usuario}
      END IF;

        /*
       {Buscamos los forms de destino, primero  los que conincidan con el campo
      , despues con el bloque, y finalmente con el formulario}
       */
      SELECT COUNT (1)
      INTO   total
      FROM   (SELECT DISTINCT form_sig
              FROM            pds_config_wizard
              WHERE           cconfwiz = c_cconfwiz
              AND             form_act = pform
              AND             sproduc = psproduc
              AND             cmodo = pmodo
              AND             campo_act = pccamptf
              AND             f_consupl_form (c_cconsupl, form_sig) = 1
              UNION
              SELECT DISTINCT form_sig
              FROM            pds_config_wizard
              WHERE           cconfwiz = c_cconfwiz
              AND             form_act = pform
              AND             sproduc = psproduc
              AND             cmodo = pmodo
              AND             f_consupl_form (c_cconsupl, form_sig) = 1
              AND             campo_act =
                                 SUBSTR (pccamptf, 0,
                                         INSTR (pccamptf, '.') - 1)
              UNION
              SELECT DISTINCT form_sig
              FROM            pds_config_wizard
              WHERE           cconfwiz = c_cconfwiz
              AND             form_act = pform
              AND             sproduc = psproduc
              AND             cmodo = pmodo
              AND             f_consupl_form (c_cconsupl, form_sig) = 1
              AND             campo_act = '*');

      RETURN total;
   END;

   FUNCTION f_modificar_campos_supl (
      pcuser     IN       VARCHAR2,
      psproduc   IN       NUMBER,
      ptform     IN       VARCHAR2,
      psseguro   IN       NUMBER,
      pcmodo     IN       VARCHAR2,
      tcampos    IN OUT   campos_modi
   )
      RETURN NUMBER
   IS
      c_consupl   VARCHAR (50);

      CURSOR motivo
      IS
         SELECT p2.cconfig
         FROM   pds_supl_cod_config p1,
                pds_supl_config p2,
                pds_estsegurosupl p3
         WHERE  p1.cconsupl = c_consupl
         AND    p1.cconfig = p2.cconfig
         AND    p2.sproduc = psproduc
         AND    p2.cmodo = pcmodo
         AND    p2.cmotmov = p3.cmotmov
         AND    p3.sseguro = psseguro
         AND    p3.cestado <> 'F';

      CURSOR campos (
         pconfig   IN   VARCHAR2
      )
      IS
         SELECT   tcampo,
                  tproperty,
                  tvalue
         FROM     pds_supl_campos_form c
         WHERE    c.cconfig = pconfig
         AND      c.tform = ptform
         ORDER BY norden;

      /* hay que crear un campo que nos indique la ordenación*/
      i_index     NUMBER       := 0;
   BEGIN
      /*
      {Primero se mira que configuración tiene el usuario asignada}
      */
      BEGIN
         SELECT cconsupl
         INTO   c_consupl
         FROM   pds_config_user
         WHERE  cuser = UPPER (pcuser);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 151746;
      END;

      IF c_consupl IS NULL THEN
         RETURN 1232131;
      --{No se ha encontrado la configuración de navegación para este usuario}
      END IF;

      /*
      {Obtenemos los motivos de suplemento que aun se pueden hacer}
      */
      FOR c IN motivo
      LOOP
          /*
         {Obtenemos los campos de los que hay que modificar las propiedades}
          */
         DBMS_OUTPUT.put_line (c.cconfig);

         FOR z IN campos (c.cconfig)
         LOOP
            tcampos (i_index).tcampo       := z.tcampo;
            tcampos (i_index).tproperty    := z.tproperty;
            tcampos (i_index).tvalue       := z.tvalue;
            i_index                        := i_index + 1;
         END LOOP;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_wizard.f_modificar_campos',
                      1,
                      'error no controlado',
                      SQLERRM
                     );
         RETURN 123131;                 --{Error en la recuperación de campos}
   END f_modificar_campos_supl;

-- AVT 17-09-2004
   FUNCTION f_modificar_campos (
      pcuser     IN       VARCHAR2,
      psproduc   IN       NUMBER,
      ptform     IN       VARCHAR2,
      pcmodo     IN       VARCHAR2,
      tcampos    IN OUT   campos_modi
   )
      RETURN NUMBER
   IS
      c_conform   VARCHAR (50);

      CURSOR campos (
         pconform   IN   VARCHAR2
      )
      IS
         SELECT   tcampo,
                  tproperty,
                  tvalue
         FROM     pds_config_form c
         WHERE    c.cconform = pconform
         AND      c.cmodo = pcmodo
         AND      c.sproduc = psproduc
         AND      c.tform = ptform
         ORDER BY norden;

      i_index     NUMBER       := 0;
   BEGIN
      /*
      {Primero se mira que configuración tiene el usuario asignada}
      */
      BEGIN
         SELECT cconform
         INTO   c_conform
         FROM   pds_config_user
         WHERE  cuser = UPPER (pcuser);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 151746;
      END;

      IF c_conform IS NULL THEN
         RETURN 1232131;
      --{No se ha encontrado la configuración de navegación para este usuario}
      END IF;

       /*
      {Obtenemos los campos de los que hay que modificar las propiedades}
       */
      FOR z IN campos (c_conform)
      LOOP
         tcampos (i_index).tcampo       := z.tcampo;
         tcampos (i_index).tproperty    := z.tproperty;
         tcampos (i_index).tvalue       := z.tvalue;
         i_index                        := i_index + 1;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_wizard.f_modificar_campos',
                      1,
                      'error no controlado',
                      SQLERRM
                     );
         RETURN 123131;                 --{Error en la recuperación de campos}
   END f_modificar_campos;

-----
   FUNCTION f_supl_form_navegable (
      pcuser     IN   VARCHAR2,
      pcmotmov   IN   NUMBER,
      psproduc   IN   NUMBER,
      pcmodo     IN   VARCHAR2,
      ptform     IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      /*
      {función que nos indica si en un formulario se puede hacer un suplemento cmotmov}
      */
      c_cconsupl   VARCHAR2 (50);
      resultat     NUMBER;
   BEGIN
      BEGIN
         SELECT cconsupl
         INTO   c_cconsupl
         FROM   pds_config_user
         WHERE  cuser = UPPER (pcuser);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;
      --{No se ha puede hacer el suplemento desde este form}
      END;

      IF c_cconsupl IS NULL THEN
         RETURN 0;
      --{No se puede hacer el suplemento desde el form}
      END IF;

      BEGIN
         SELECT COUNT (1)
         INTO   resultat
         FROM   pds_supl_form c1, pds_supl_config c, pds_supl_cod_config f
         WHERE  f.cconsupl = c_cconsupl
         AND    f.cconfig = c.cconfig
         AND    c.cmotmov = pcmotmov
         AND    c.sproduc = psproduc
         AND    c.cconfig = c1.cconfig
         AND    c1.tform = ptform;
      END;

      IF resultat > 1 THEN
         resultat    := 1;
      END IF;

      RETURN resultat;
   END;

   PROCEDURE p_borrar_visitado (
      psseguro   IN   NUMBER,
      ptform     IN   VARCHAR2
   )
   IS
   BEGIN
      DELETE      pds_estsigform
      WHERE       sseguro = psseguro
      AND         tform = ptform;
   END p_borrar_visitado;

   FUNCTION f_get_accion (
      pcuser     IN   VARCHAR2,
      pcaccion   IN   VARCHAR2,
      psproduc   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      c_cconacc   VARCHAR2 (50);
      c_caccion   VARCHAR2 (50);
   BEGIN
      /*
      {Función que nos indica si un usario puede (1) o no puede realizar una acción}
      */
      BEGIN
         SELECT cconacc
         INTO   c_cconacc
         FROM   pds_config_user
         WHERE  cuser = UPPER (pcuser);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;                         --{   no puede hacer la acción}
      END;

      IF c_cconacc IS NULL THEN
         RETURN 0;                               --{no puede hacer la acción}
      END IF;

      IF psproduc IS NULL THEN
         BEGIN
            SELECT caccion
            INTO   c_caccion
            FROM   pds_config_accion
            WHERE  cconacc = c_cconacc
            AND    caccion = pcaccion;
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  SELECT caccion
                  INTO   c_caccion
                  FROM   pds_config_accion
                  WHERE  cconacc = c_cconacc
                  AND    caccion = pcaccion
                  AND    sproduc = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 0;                   --{no puede hacer la acción}
               END;
         END;
      ELSE
         BEGIN
            SELECT caccion
            INTO   c_caccion
            FROM   pds_config_accion
            WHERE  cconacc = c_cconacc
            AND    caccion = pcaccion
            AND    sproduc = psproduc;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT caccion
                  INTO   c_caccion
                  FROM   pds_config_accion
                  WHERE  cconacc = c_cconacc
                  AND    caccion = pcaccion
                  AND    sproduc = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 0;
               END;
         END;
      END IF;

      RETURN 1;                                      --{Puede hacer la acción}
   END;
END pac_wizard;

/

  GRANT EXECUTE ON "AXIS"."PAC_WIZARD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_WIZARD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_WIZARD" TO "PROGRAMADORESCSI";
