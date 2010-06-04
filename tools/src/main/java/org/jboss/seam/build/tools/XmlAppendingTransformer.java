package org.jboss.seam.build.tools;

import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.util.Iterator;
import java.util.List;
import java.util.jar.JarEntry;
import java.util.jar.JarOutputStream;

import org.apache.maven.plugins.shade.resource.ResourceTransformer;
import org.jdom.Attribute;
import org.jdom.Content;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class XmlAppendingTransformer implements ResourceTransformer
{
   
   String resource;

   private Document doc;

   public boolean canTransformResource(String resource)
   {
      if ( this.resource != null && this.resource.equalsIgnoreCase( resource ) )
      {
          return true;
      }

      return false;
   }

   public boolean hasTransformedResource()
   {
      return doc != null;
   }

   public void modifyOutputStream(JarOutputStream os) throws IOException
   {
      os.putNextEntry(new JarEntry(resource));

      new XMLOutputter(Format.getPrettyFormat()).output(doc, os);

      doc = null;
   }

   public void processResource(String resource, InputStream is, List relocators) throws IOException
   {
      Document r;
      try
      {
         SAXBuilder builder = new SAXBuilder(false);
         builder.setExpandEntities(false);
         builder.setEntityResolver(new EntityResolver()
         {
            public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException
            {
               return new InputSource(new StringReader(""));
            }
         });
         // Allow empty files
         if (is.available() == 0)
         {
            return;
         }
         r = builder.build(is);
      }
      catch (JDOMException e)
      {
         throw new RuntimeException(e);
      }

      if (doc == null)
      {
         doc = r;
      }
      else
      {
         Element root = r.getRootElement();

         for (Iterator itr = root.getAttributes().iterator(); itr.hasNext();)
         {
            Attribute a = (Attribute) itr.next();
            itr.remove();

            Element mergedEl = doc.getRootElement();
            Attribute mergedAtt = mergedEl.getAttribute(a.getName(), a.getNamespace());
            if (mergedAtt == null)
            {
               mergedEl.setAttribute(a);
            }
         }

         for (Iterator itr = root.getChildren().iterator(); itr.hasNext();)
         {
            Content n = (Content) itr.next();
            itr.remove();

            doc.getRootElement().addContent(n);
         }
      }
   }

}
