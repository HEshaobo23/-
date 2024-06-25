
    public LoginVO login(String account, String password, HttpProxy httpProxy) throws IOException {
        if (httpProxy == null) {
            String url = sysConfigService.selectConfigByKey("sys:ip.master");
            String open = sysConfigService.selectConfigByKey("sys:ip:open");
            String cache = sysConfigService.selectConfigByKey("sys:ip:cache");
            String openZxjy = sysConfigService.selectConfigByKey("sys:ip:open_zxjy");
            httpProxy = new HttpProxy(url, open, cache, "yes".equals(openZxjy));
        }
        CloseableHttpClient httpClient = HttpClientBuilder.create().build();
        HttpPost httpGet = new HttpPost(TOKEN_API);
        httpGet.setHeader("content-type", "application/json");
        CloseableHttpResponse response = null;
        StringEntity entity = new StringEntity("", Consts.UTF_8);
        httpGet.setEntity(entity);
        String result;
        try {
            response = httpClient.execute(httpGet);
            HttpEntity entity1 = response.getEntity();
            result = EntityUtils.toString(entity1);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        ApiResponse tokenVo = JSONUtil.toBean(result, ApiResponse.class);
        //0e433bbcdafb06edab4f9c1952580233bc84
        JSONObject data = new JSONObject();
        String dToken = configService.selectConfigByKey("sys.public.key");
        data.set("phone", account)
                .set("password", SecureUtil.md5(password))
                .set("dtype", 6)
                .set("dToken", "0");
        String token = validationToken();
        String jsonStr = JSONUtil.toJsonStr(data);

        String sign = hmacSha256(jsonStr + tokenVo.getData().getApitoken(), "Anything_2023");
        SysDictData sysDictData = new SysDictData();
        //邮箱模板
        sysDictData.setDictType("sys_phone_types");
        List<SysDictData> dataList = SysDictDatas(sysDictData);
        int count = RandomUtil.randomInt(0, dataList.size() - 1);
        String phonetype = dataList.get(count).getDictValue();
        long currentTimeMillis = System.currentTimeMillis();

        CloseableHttpClient httpClient1 = HttpClientBuilder.create().build();
        HttpPost httpGet1 = new HttpPost(ApiConfig.LOGIN_API);
        httpGet1.setHeader("content-type", "application/json");
        httpGet1.setHeader("Sign", sign);
        httpGet1.setHeader("appVersion", "57");
        httpGet1.setHeader("os", "android");
        httpGet1.setHeader("cl_ip", httpProxy.getIp());
        httpGet1.setHeader("User-Agent", "okhttp/3.14.9");
        httpGet1.setHeader("timestamp", String.valueOf(currentTimeMillis));
        httpGet1.setHeader("phone", phonetype);
        httpGet1.setHeader("token", tokenVo.getData().getApitoken());
        CloseableHttpResponse response1 = null;
        StringEntity entity1 = new StringEntity(jsonStr, Consts.UTF_8);
        httpGet1.setEntity(entity1);
        String result1 = null;

        try {
            response = httpClient.execute(httpGet1);
            HttpEntity entity2 = response.getEntity();
            result1 = EntityUtils.toString(entity2);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        LoginVO loginVO = JSONUtil.toBean(result1, LoginVO.class);
        if (false) {
            JSONObject data1 = new JSONObject();
            data1
                    .set("uid", loginVO.getData().getUid())
                    .set("dtype", 2)
            ;
            String jsonStr1 = JSONUtil.toJsonStr(data1);
            String sign1 = hmacSha256(jsonStr1 + loginVO.getData().getToken(), "Anything_2023");
            MediaType mediaType = MediaType.parse("application/json");
            OkHttpClient client = new OkHttpClient.Builder()
                    .connectTimeout(2, TimeUnit.SECONDS) // 设置连接超时时间为10秒
                    .readTimeout(2, TimeUnit.SECONDS) // 设置读取超时时间为30秒
                    .build();
            ObjectMapper objectMapper = new ObjectMapper();
            String json = objectMapper.writeValueAsString(data1);
            RequestBody formBody = RequestBody.create(mediaType, json);
            Request.Builder request3 = new Request.Builder()
                    .url("https://sxbaapp.zcj.jyt.henan.gov.cn/api/relog.ashx")
                    .post(formBody);
            request3.header("content-type", "application/json");
            request3.header("Sign", sign1);
            request3.header("appVersion", "57");
            request3.header("os", "android");
            request3.header("cl_ip", httpProxy.getIp());
            request3.header("User-Agent", "okhttp/3.14.9");
            request3.header("timestamp", String.valueOf(currentTimeMillis));
            request3.header("phone", phonetype);


            try {
                request3.header("token", loginVO.getData().getToken());
                Request request = request3.build();
                Response response2 = client.newCall(request).execute();
                String responseData = response2.body().string();
                test01.toJson(responseData, account, password, "10001");
            } catch (IOException e) {
                throw new RuntimeException(e);
            }


        }

        if (1001 == loginVO.getCode()) {
            String uid = loginVO.getData().getUid();
            //缓存只有三天有效
            RedisUtils.setCacheObject(userKey + account + ":uid", uid, Duration.ofDays(3));
            return loginVO;
        }

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date date = new Date();
        String format = dateFormat.format(date);
        PunchCardVo punchCardVo = punchCardMapper.selectVoOne(new QueryWrapper<PunchCard>().eq("dk_phone", account).eq("is_del", 1));
        if (punchCardVo == null) {
            if (1002 == loginVO.getCode()) {
                return loginVO;
            }
        }
        PunchCard punchCard = new PunchCard();
        punchCard.setLogs(loginVO.getMsg() + " 时间：" + format);
        punchCard.setId(punchCardVo.getId());
        punchCardMapper.updateById(punchCard);

        throw new RuntimeException("登录失败原因" + loginVO.getMsg() + "可能是" + account + "账户或者密码错误！");


    }
