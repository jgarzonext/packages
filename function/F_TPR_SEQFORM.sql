--------------------------------------------------------
--  DDL for Function F_TPR_SEQFORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TPR_SEQFORM" (psproduc in number,pcramo in number,pcmodali in number,pctipseg in number,pccolect in number,pcactivi in number,puser in varchar2, 
                                         pcmotmov in number, psform out number, pctipo in number default 1) RETURN NUMBER AUTHID CURRENT_USER IS
/*********************************************************************************************
 SLS f_tpr_seqform: Función que nos devuelve el número de secuencia a ejecutar para el tipo
                    de movimiento, producto, perfil usuario de formularios, tanto de nueva producción
                    como suplementos, como cualquier otro tipo de secuencias a ejecutar. (10-03-2004)

*********************************************************************************************/
salida   exception;
error    number:=0;
psproces number:=0; --
paso     number:=0; -- Variable definida para saber en que paso nos encontramos, o nos hemos quedado

BEGIN

/* Esta función se llama desde los módulos de mantenimiento de personas
   Crédit no necesita estos controles y configuraciones por usuario 
*/
psform := 336;

--- Inicializamos las llamadas de debug
/*
   pac_mgr_session.err := pac_mgr_session.f_push('F_TPR_SEQFORM');
   if pac_mgr_session.f_debug then
      pac_mgr_session.p_mensajedebug('- psproduc > '||psproduc|| '<');
     pac_mgr_session.p_mensajedebug('- pcramo   > '||pcramo  || '<');
     pac_mgr_session.p_mensajedebug('- pcmodali > '||pcmodali|| '<');
     pac_mgr_session.p_mensajedebug('- pctipseg > '||pctipseg|| '<');
     pac_mgr_session.p_mensajedebug('- pccolect > '||pccolect|| '<');
     pac_mgr_session.p_mensajedebug('- pcactivi > '||pcactivi|| '<');
     pac_mgr_session.p_mensajedebug('- puser    > '||puser||    '<');
     pac_mgr_session.p_mensajedebug('- pcmotmov > '||pcmotmov|| '<');

   end if;

 paso:=1;
 IF pctipo = 1 THEN
       BEGIN
          select sform
            into psform
            from conf_prodmotmov p, conf_configuraciones c, conf_userconfuser u
           where u.cusuari   = puser
             and c.cconfuser = u.cconfuser
             and p.cconfuser = c.cconfuser
             and p.cconfig   = c.cconfig
             and p.sproduc   = psproduc
             and p.cmotmov   = pcmotmov;
      
       EXCEPTION
         WHEN OTHERS THEN
             error:=sqlcode;
             raise salida;
       END;
       
  ELSIF pctipo = 2 THEN
  
         BEGIN
          select sform
            into psform
            from conf_instalseq p, conf_configuraciones c, conf_userconfuser u
           where u.cusuari   = puser
             and c.cconfuser = u.cconfuser
             and p.cconfuser = c.cconfuser
             and p.cconfig   = c.cconfig
             and p.ctipo     = pctipo;
      
       EXCEPTION
       
         WHEN OTHERS THEN
             error:=sqlcode;
             raise salida;
       END;
  ELSE
    NULL;
  END IF;
 paso:=2;

 raise salida;

EXCEPTION
  WHEN salida THEN
   IF pac_mgr_session.f_debug THEN
      pac_mgr_session.p_mensajedebug('- psproduc > '||psproduc|| '<');
     pac_mgr_session.p_mensajedebug('- pcramo   > '||pcramo  || '<');
     pac_mgr_session.p_mensajedebug('- pcmodali > '||pcmodali|| '<');
     pac_mgr_session.p_mensajedebug('- pctipseg > '||pctipseg|| '<');
     pac_mgr_session.p_mensajedebug('- pccolect > '||pccolect|| '<');
     pac_mgr_session.p_mensajedebug('- pcactivi > '||pcactivi|| '<');
     pac_mgr_session.p_mensajedebug('- puser    > '||puser||    '<');
     pac_mgr_session.p_mensajedebug('- pcmotmov > '||pcmotmov|| '<');

       pac_mgr_session.p_mensajedebug('Valores de los parámetros OUT');
          pac_mgr_session.p_mensajedebug(' Out error  >'|| error    ||'<');
          pac_mgr_session.p_mensajedebug(' Out psform  >'|| psform    ||'<');
     pac_mgr_session.err := pac_mgr_session.f_pop('When Salida');
   END IF;
   return error;

  WHEN others THEN
   pac_mgr_session.tsqlerr := sqlerrm;
   error := -1;
   IF pac_mgr_session.f_debug THEN
      pac_mgr_session.p_mensajedebug('Valores de los parámetros OUT');
      pac_mgr_session.p_mensajedebug(' Out error  >'|| error    ||'<');
      pac_mgr_session.p_mensajedebug(' Out psform      >'||psform ||'<');
      pac_mgr_session.p_mensajedebug(' salida por paso >'||paso   ||'<');
      pac_mgr_session.err := pac_mgr_session.f_pop('When Others');
   END IF;
*/
   return error;
END F_TPR_SEQFORM; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TPR_SEQFORM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TPR_SEQFORM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TPR_SEQFORM" TO "PROGRAMADORESCSI";
