--------------------------------------------------------
--  DDL for Package Body PAC_MD_SUPL_DIRIGIDOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_SUPL_DIRIGIDOS" AS
   /******************************************************************************
    NOMBRE:      pac_md_supl_dirigidos
    PROPÓSITO:   Interficie para cada tipo de suplemento

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        28/07/2009   JRH                1. Creación del package. Bug 10776 reducción total
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
        Acciones a hacer para la reduccion total de una póliza
        param in psseguro    : código del seguro
        param out mensajes   : colección de mensajes
        return               : 0 todo ha ido bien
                               1 se ha producido un error
     *************************************************************************/
   FUNCTION f_reduccion_total(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'pac_md_supl_dirigidos.f_reduccion_total';
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      rie            ob_iax_riesgos;
      gar            t_iax_garantias;
      tgr            ob_iax_garantias;
      nerr           NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM estseguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- Se modifica el capital de la garantía de la prima periódica
      UPDATE estgaranseg
         SET icapital = 0
       WHERE sseguro = psseguro
         AND f_pargaranpro_v(vcramo, vcmodali, vctipseg, vccolect,
                             pac_seguros.ff_get_actividad(psseguro, estgaranseg.nriesgo, 'EST'),
                             cgarant, 'TIPO') = 3;

      --dbms_output.put_line('HOLAAAAAAAAAAAAAAAAA:'||sql%rowcount);
      vpasexec := 3;

      -- Se modifica forma de pago en SEGUROS a 0
      UPDATE estseguros
         SET cforpag = 0,
             fcarpro = NULL,
             fcaranu = NULL,
             nrenova = NULL
       WHERE sseguro = psseguro;

      vpasexec := 4;

      -- Se calculan y modifican los nuevos valores de Fecha cartera próxima, Fecha cartera anualidad y Día y mes renovación

      -- Anulación de las garantias de riesgo vigentes en la póliza
      -- Bug 9685 - APD - 21/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      UPDATE estgaranseg
         SET cobliga = 0
       WHERE sseguro = psseguro
         AND f_pargaranpro_v(vcramo, vcmodali, vctipseg, vccolect,
                             pac_seguros.ff_get_actividad(psseguro, estgaranseg.nriesgo, 'EST'),
                             cgarant, 'TIPO') IN(6, 7);

      pac_iax_produccion.poliza.det_poliza.gestion.fcarpro := NULL;
      pac_iax_produccion.poliza.det_poliza.gestion.fcaranu := NULL;
      pac_iax_produccion.poliza.det_poliza.nrenova := NULL;
      pac_iax_produccion.poliza.det_poliza.gestion.cforpag := 0;
      vpasexec := 2;
      rie := pac_iobj_prod.f_partpolriesgo(pac_iax_produccion.poliza.det_poliza, 1, mensajes);

      IF rie IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      vpasexec := 4;
      gar := pac_iobj_prod.f_partriesgarantias(rie, mensajes);

      IF gar IS NULL THEN
         gar := t_iax_garantias();
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 5;
            RAISE e_object_error;
         END IF;
      END IF;

      IF gar IS NOT NULL THEN
         IF gar.COUNT > 0 THEN
            FOR vgar IN gar.FIRST .. gar.LAST LOOP
               IF gar.EXISTS(vgar) THEN
                  IF f_pargaranpro_v(vcramo, vcmodali, vctipseg, vccolect,
                                     pac_seguros.ff_get_actividad(psseguro, 1, 'EST'),
                                     gar(vgar).cgarant, 'TIPO') = 3 THEN
                     vpasexec := 12;
                     gar(vgar).icapital := 0;
                  END IF;

                  IF f_pargaranpro_v(vcramo, vcmodali, vctipseg, vccolect,
                                     pac_seguros.ff_get_actividad(psseguro, 1, 'EST'),
                                     gar(vgar).cgarant, 'TIPO') IN(6, 7) THEN
                     vpasexec := 12;
                     gar(vgar).cobliga := 0;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      vpasexec := 14;
      nerr := pac_iobj_prod.f_set_partriesgarantias(pac_iax_produccion.poliza.det_poliza, 1,
                                                    gar, mensajes);

      IF nerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001102);
         vpasexec := 14;
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_reduccion_total;
END pac_md_supl_dirigidos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SUPL_DIRIGIDOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SUPL_DIRIGIDOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SUPL_DIRIGIDOS" TO "PROGRAMADORESCSI";
