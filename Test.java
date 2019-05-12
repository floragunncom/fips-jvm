import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.security.MessageDigest;

import javax.crypto.Cipher;
import javax.net.ssl.HttpsURLConnection;

public class Test {

    public static void main(String[] args) {
        try {
            System.setProperty("javax.net.ssl.trustStorePassword", "changeit");
            int maxKeyLen = Cipher.getMaxAllowedKeyLength("AES");
            System.out.println("MAX AES key len ok?: " + (maxKeyLen > 128));

            byte[] d = MessageDigest.getInstance("SHA3-256", "BCFIPS").digest(new byte[] { 1, 2, 3 });

            System.out.println("SHA-3 BCFIPS digest ok?: "+(d!= null && d.length == 32 ));
            
            
            String httpsURL = "https://www.google.com/";
            URL myUrl = new URL(httpsURL);
            HttpsURLConnection conn = (HttpsURLConnection)myUrl.openConnection();
            InputStream is = conn.getInputStream();
            InputStreamReader isr = new InputStreamReader(is);
            BufferedReader br = new BufferedReader(isr);

            String inputLine;

            while ((inputLine = br.readLine()) != null) {
                break;
            }

            br.close();

            System.out.println("BCFKS cacerts working!");
           
        } catch (Throwable e) {
            System.out.println(e.getMessage());
            e.printStackTrace();
        }
    }

}
