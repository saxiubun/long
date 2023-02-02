package com.domed.util;

import javax.crypto.Cipher;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESedeKeySpec;
import javax.crypto.spec.IvParameterSpec;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.security.Key;

public class Des3Util {
	public static final boolean IS_ENCRY = true ;  //是否加密

//    public static final String CODE_KEY  = "ztesoftbasemobile20160812.." ;   //加密秘钥
    public static final String CODE_KEY  = "ztesoftmobileframework.." ;   //加密秘钥
    public static final String  IV = "01234567"; // 向量

    public static final String ENCODE_SET = "utf-8";// 加解密统一使用的编码方式

    /**
     * 使用自定义密匙的DES3加密
     *
     * @param plainText
     *            原文
     * @param customKey
     *            自定义密匙
     * @return 密文
     * @throws Exception
     */
    public static String encryptWithKey(String plainText, String customKey)
            throws Exception {

        Key deskey = null;
        DESedeKeySpec spec = new DESedeKeySpec(customKey.getBytes());
        SecretKeyFactory keyfactory = SecretKeyFactory.getInstance("DESede");
        deskey = keyfactory.generateSecret(spec);
        Cipher cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
        IvParameterSpec ips = new IvParameterSpec(IV.getBytes());
        cipher.init(Cipher.ENCRYPT_MODE, deskey, ips);
        byte[] encryptData = cipher.doFinal(plainText.getBytes(ENCODE_SET));
        return Base64.encode(encryptData);
    }

    /**
     * 使用默认密匙的DES3加密
     * @param plainText 原文
     * @return 密文
     * @throws Exception
     */
    public static String encrypt(String plainText) throws Exception {
        return Des3Util.encryptWithKey(plainText, CODE_KEY);
    }


    /**
     * 使用自定义密匙的DES3解密
     * @param encryptText 密文
     * @param customKey  自定义密匙
     * @return 原文
     * @throws Exception
     */
    public static String decryptWithKey(String encryptText, String customKey)
            throws Exception {

        Key deskey = null;
        SecretKeyFactory keyfactory = SecretKeyFactory.getInstance("DESede");
        DESedeKeySpec spec = new DESedeKeySpec(customKey.getBytes());
        keyfactory.generateSecret(spec);
        deskey = keyfactory.generateSecret(spec);
        Cipher cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
        IvParameterSpec ips = new IvParameterSpec(IV.getBytes());
        cipher.init(Cipher.DECRYPT_MODE, deskey, ips);
        byte[] decryptData = cipher.doFinal(Base64.decode(encryptText));
        return new String(decryptData, ENCODE_SET);

    }


    /**
     * 使用默认密匙的DES3解密
     * @param encryptText 密文
     * @return 原文
     * @throws Exception
     */
    public static String decrypt(String encryptText) throws Exception {
        return Des3Util.decryptWithKey(encryptText, CODE_KEY);
    }


    public static String padding(String str) {
        byte[] oldByteArray;
        try {
            oldByteArray = str.getBytes("UTF8");
            int numberToPad = 8 - oldByteArray.length % 8;
            byte[] newByteArray = new byte[oldByteArray.length + numberToPad];
            System.arraycopy(oldByteArray, 0, newByteArray, 0,
                    oldByteArray.length);
            for (int i = oldByteArray.length; i < newByteArray.length; ++i) {
                newByteArray[i] = 0;
            }
            return new String(newByteArray, "UTF8");
        } catch (UnsupportedEncodingException e) {
            System.out.println("Crypter.padding UnsupportedEncodingException");
        }
        return null;
    }


    /**
     * Base64编码工具类
     */
    public static class Base64 {
        private static final char[] legalChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".toCharArray();
        public static String encode(byte[] data) {
            int start = 0;
            int len = data.length;
            StringBuffer buf = new StringBuffer(data.length * 3 / 2);
            int end = len - 3;
            int i = start;
            int n = 0;
            while (i <= end) {
                int d = ((((int) data[i]) & 0x0ff) << 16)
                        | ((((int) data[i + 1]) & 0x0ff) << 8)
                        | (((int) data[i + 2]) & 0x0ff);
                buf.append(legalChars[(d >> 18) & 63]);
                buf.append(legalChars[(d >> 12) & 63]);
                buf.append(legalChars[(d >> 6) & 63]);
                buf.append(legalChars[d & 63]);
                i += 3;
                if (n++ >= 14) {
                    n = 0;
                    buf.append("");
                }
            }
            if (i == start + len - 2) {
                int d = ((((int) data[i]) & 0x0ff) << 16)
                        | ((((int) data[i + 1]) & 255) << 8);
                buf.append(legalChars[(d >> 18) & 63]);
                buf.append(legalChars[(d >> 12) & 63]);
                buf.append(legalChars[(d >> 6) & 63]);
                buf.append("=");
            } else if (i == start + len - 1) {
                int d = (((int) data[i]) & 0x0ff) << 16;
                buf.append(legalChars[(d >> 18) & 63]);
                buf.append(legalChars[(d >> 12) & 63]);
                buf.append("==");
            }
            return buf.toString();
        }

        private static int decode(char c) {
            if (c >= 'A' && c <= 'Z'){
                return ((int) c) - 65;
            }else if (c >= 'a' && c <= 'z'){
                return ((int) c) - 97 + 26;
            }else if (c >= '0' && c <= '9'){
                return ((int) c) - 48 + 26 + 26;
            }else{
                switch (c) {
                    case '+':
                        return 62;
                    case '/':
                        return 63;
                    case '=':
                        return 0;
                    default:
                        throw new RuntimeException("unexpected code: " + c);
                }
            }

        }

        public static byte[] decode(String s) {
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            try {
                decode(s, bos);
            } catch (IOException e) {
                throw new RuntimeException();
            }
            byte[] decodedBytes = bos.toByteArray();
            try {
                bos.flush();
                bos.close();
                bos = null;
            } catch (IOException ex) {
                System.err.println("Error while decoding BASE64: "
                        + ex.toString());
            }
            return decodedBytes;
        }

        private static void decode(String s, OutputStream os)
                throws IOException {
            int i = 0;
            int len = s.length();
            while (true) {
                while (i < len && s.charAt(i) <= ' '){
                    i++;

                }
                if (i == len){
                    break;
                }
                int tri = (decode(s.charAt(i)) << 18)
                        + (decode(s.charAt(i + 1)) << 12)
                        + (decode(s.charAt(i + 2)) << 6)
                        + (decode(s.charAt(i + 3)));
                os.write((tri >> 16) & 255);
                if (s.charAt(i + 2) == '='){
                    break;
                }
                os.write((tri >> 8) & 255);
                if (s.charAt(i + 3) == '='){
                    break;
                }
                os.write(tri & 255);
                i += 4;
            }
        }
    }


    /**
     * json解密传输接收函数，通过这个函数，将输入的JSON串，自动解密、特殊处理，业务层直接可以用此返回结果的字符串进行处理
     * @param response
     * @return
     */
    public static String decryptTransportResponse(String response) throws Exception{
//        Log.e(TAG, "decryptTransportResponse input params is " + response.toString());
//        System.out.println("decryptTransportResponse input params is "+response.toString());
    	if (null == response) {
            return null;
        }
        String _mstr ;
        //去除头部{"result":"   {"result":"
        _mstr = response.replaceFirst("\\{\"kZXy1B5\":\"","");
       //去除尾部"}
        _mstr = _mstr.replace("\"}", "");
        //将所有@替换为+
        _mstr = response.replaceAll("@","\\+");
        //进行解密
        try {
            _mstr = Des3Util.decryptWithKey(_mstr, Des3Util.CODE_KEY);
        } catch (Exception e) {
            e.printStackTrace();
        }

//        System.out.println("decryptTransportResponse output result is "+_mstr);
        return  _mstr;
//        return response;
    }

    /**
     * 测试主方法，可以和手机端的得到相同加密解密结果
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
    	String s = "DOCk5WDqCgvDLU8TKf5+41bVyOn0fcnirtSAWksfbbIU6ClXYChG/3C/FC+j75UjRflvDMp0v73CxrkaoJIxuJuphjjwrW6RJRYozSoNheTH4yBOek6txuVjDgVbCy8JDhi9/+sw5tYV2XKWc4879bQrR2E9LsEA2zdivg4PxcwGa9O+V/VPiX1Z9K66grl1eJN3/cHu3eVN76TstrpUiVolnfBVqTMbG3qNduvGQpASlX785UUjQ6ointtJxyOdS00iWHvENQ5ieRVTEpRmQrCtWUnu3QKWPRkfzs05hAGXaVGoqkku47QbyWscBIYq";
    	String ss = Des3Util.decryptTransportResponse(s);
    	System.out.println(ss);
//        String plainText =
//                "{\"device_info\":{\"imsi\":\"imsi\",\"phoneNumber\":\"13301270810\",\"imei\":\"ime411\",\"platform\":\"2\",\"model\":\"model\",\"channelId\":\"4915206817937530785\",\"mac\":\"mac\"},"+
//                        "\"body\":{\"user_name\":\"ldy\",\"pwd\":\"kkk\",\"ip\":\"10.58.67.154\"}}";
        //plainText = "{\"body\":{\"appVersionId\":\"108\"},\"session_id\":\"A7542EBD6C165AA589D350A979B639EC\"}";
//        System.out.println(plainText);
//        String key = "ztesoftmobileframework..";
//        String encryptedText = "+MEUtt/6okv1xv4HNJ1+I/Qwg5AXncgYpsJ2Jf3jXwCLbBuiBSZ5nh3GTwBBJECuEtJnCrgVCxTN1Kf023v7FIJRfga+5TAG1jNCAacRqy1eScl1rd6RF7v0EWvfLwSFudqw+iazpf7wUfv+G8JMCEa9qzClY95LtQyXMNRscb0Q1CC9NEfzmmSN/jtSj7W6tItq2+H5uRDJjCB0dVIMGmDvwoYYKW9Fb/9IjnwnM/7uGO4odbC3eha2qgasEBFYxbNm9nLZJMty7NSQIUdGwfWnHhlVRlZYvFt4gSaa9zBfg6TPwBpF4qLuQDrV/CDYDnSFg2LUYIeu4v+bngoV4aYVGllKjiSGp2qP7lRDQbEIAefPJEHrP9k4g/CnnBtRjCKicii+/JA=";
//        String encryptedText = "UtEgoletBUKTjbQC8F@05xmayHltgQiDGKyCBlfwiwy23IR8qbQeeODMwRb/fu8n3IrcBAXslqcZ82KDDCcgm95IKwZOFbilKMeuE@ijCbcYjvyMH3APRXCM5a0Vg3vVTtyRpMG8Avr1F2O0iSLtJA7mS/WeGIxJSnF4Z57EP@GJrk4m4oqR01qVG9w6TRjEI/PvCQ2phAclRrM/YsKF8iy5lQWedfNoSFQMTYQbcBGLxhEt/hsoWMD88FIELyIZHDTgKSkGkLX7Omu8ZpOUDseM8yPDwW/8froOQ35FFUizY3X3ouwSZIjEVgmJgjjNs3FrUmukZVJjSEyN1jMPkjjSQU9PVCr7IDjaVv9JMT8wWmwBPe8HJ/ZV6iIFAiSt8WtNWtJSDxib0XOWvsucqO4auy4Out37cr06bhaVL2w7zPBs00GmMt7EvJKCODToMOw6q9C3l1I=";
//        System.out.println(Des3Util.decryptTransportResponse(encryptedText));
//        String text = encryptedText.replaceAll("@","\\+");
//        System.out.println(text);
//        String decryptText = Des3Util.encrypt(text);
//        System.out.println(decryptText);
//        String str2 = "{\"content\":{\"method\":\"ZYD_TRANS_PARTY\",\"param\":{\"ORG_ID\":\"1\"}},\"method\":\"executeJson\"}";
//        String str3 = "{\"username\":\"huangze\"}";
//        String str4 = "{\\\"kZXy1B5\\\":\\\"3TKWOtsl2sJZpUkrUml2cuR9U9vPOlIDazOylfpPW7N96p62Sqk2Y9F14StWDZi9ZoBymEiUt8nia46VcGMGvkyF1edBXHRN/xlXE1C1OGlDTB04Yb6C17uNhEo2c9@FMvQR2k29anoYlbSEcq7M5ECFwnPCxHcFZNyV3sJivk5SSyBqV7NHAvsG1mhGkoIEAoP18CJvfUMfxdRnvypbDeDj/@KEX5el\\\"}";
//        String str5 = "{\"method\":\"executeJson\",\"content\":{\"param\":{\"staffId\":\"1\"},\"method\":\"QUERY_HOME_PAGE_NUM\"}}";
//        String str6 = "{\n" +
//                "    \"username\": \"iom\",\n" +
//                "    \"password\": \"iom123456\"\n" +
//                "}";
//        String str7 = "{\n" +
//                "    \"staffId\": \"86066280\",\n" +
//                "    \"jobId\": \"60652\",\n" +
//                "    \"isNormal\": \"1\"\n" +
//                "}";
//        String str9 = "3TKWOtsl2sJZpUkrUml2cg@lnSDmQ9Ffb4nXezkiUKL@bMSbeaxiXt0ePTL8dNqkKb5IWv3D@tQ=";
//        String ss = str9.replaceAll("@","+");
//        String str10 = "O2AGx5rAWQo6oYJHXplUGlcBS5xqfJYu4elK6ySyFy/inSsPjAcnjdE1PbjEBvLvokWNHyDAkIhtcO//DL1nBJRgdO62aDWO8SlWgIMn8rTn6AbnSF4xIyAZ/pcW0onzCNay5XXwrHihDsCQiJksyBryFgfEzL8W/4+Ofikcfl2Ha7o7ldstyWGQL1V8egs9udhm+TBBG0hj5MgZLxx3mqEH2amIMUh/o/8aC5Iy/NXq22BfcH+fWQAhEic2QnStvC6e56mG5qcMitdwyHkuTeZrp4FTxELZwYjwWpSdFX9ktldZYBljW3kkh8LQ6Z5XtPJahnrzzPIa9Fo5uUpoXk54c9HI0PM3+YYL3x63Hgo=";
//        System.out.println(Des3Util.encrypt(str2));
//        System.out.println(Des3Util.decrypt(str10));

//        JSONObject jsonObject = new JSONObject();
//        jsonObject.put("mainId","");
//        jsonObject.put("taskId","");
//        jsonObject.put("sheetId","");
//        jsonObject.put("imageUrl1","");
//        jsonObject.put("imageUrl2","");
//        jsonObject.put("imageUrl3","");
//        JSONObject params = new JSONObject();
//        params.put("opType","gx_op122");
//        params.put("requestJson",jsonObject.toString());
//        JSONObject request = new JSONObject();
//        request.put("params",params.toString());
//        System.out.println(request.toString());
//        String s = "{\"opType\":\"gx_op122\",\"requestJson\":{\"mainId\":\"\",\"taskId\":\"\",\"sheetId\":\"\",\"imageUrl1\":\"\",\"imageUrl2\":\"\",\"imageUrl3\":\"\"}}";
//        System.out.println(s);

/*        Map<String, Object> paramMap = new HashMap<String,Object>();
        paramMap.put("sheetId", "");
        paramMap.put("taskId", "");
        paramMap.put("mainId", "");
        paramMap.put("imageUrl1", "");
        paramMap.put("imageUrl2", "");
        paramMap.put("imageUrl3", "");

        Map<String, Object> requestMap = new HashMap<String,Object>();
        requestMap.put("opType", "gx_op103");
        requestMap.put("requestJson", paramMap);
        System.out.println(requestMap.toString());*/
    }
}
