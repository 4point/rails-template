rails-template
==============

Our Rails template

Make sure that you installed Node.js on your system.

	`rails new project -m template.rb`

### 一些說明

- 以下兩個已新增在 application_controller，這樣可以依據開發環境不同，正確顯示 url，且防止 ip spoofing

	    @_root_url = request.protocol + host
    	@_full_url = @_root_url + request.fullpath


### 注意事項

- gem ransack 不能使用 start, order, type, date 等 key，所以要避免 order_date, start_time, end_time, xxxtype 等欄位命名方式，否則後台搜尋會失效；仍需要研究別的作法來解決這個問題
