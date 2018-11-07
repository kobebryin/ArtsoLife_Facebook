# devtools::install_github("ropensci/RSelenium") # Install {devtools} first
library(RSelenium) # R Bindings for Selenium WebDriver
library(data.table)

#參考文件: http://www.rpubs.com/kh555069/rsel811
#Step 1. 將Chrome web driver(chromedriver.exe)放至google chrome.exe同一個資料夾路徑(default: C:\Program Files (x86)\Google\Chrome\Application)
#Step 2. 將電腦環境變數PATH中加入步驟一chromedriver.exe的路徑(default: C:\Program Files (x86)\Google\Chrome\Application)
#Step 3. 下載selenium-server-standalone-3.9.1，利用cmd輸入指令'java -jar selenium-server-standalone-3.9.1.jar' 執行
#Step 4. selenium-server-standalone-3.9.1.jar Run起來後，就可以執行已下程式碼

## statup Rselenium and webservice
remDr <- remoteDriver(browserName = "chrome")
remDr$open() #open chrome browser

## login facebook
url2="https://www.facebook.com/messages/t/kobebryin"   #facebook massenger url(last url is fb user's id)
remDr$navigate(url2)
email_textarea <- remDr$findElement('xpath', '//*[@id="email"]')   #navigate to email textarea
email_textarea$sendKeysToElement(list("artsolife@gmail.com"))
password_textarea <- remDr$findElement('xpath', '//*[@id="pass"]')   #navigate to password textarea
password_textarea$sendKeysToElement(list("0927879090"))
login_btn <- remDr$findElement('xpath', '//*[@id="loginbutton"]')   #navigate to login button
login_btn$clickElement()

## write massege and send it
message_textarea <- remDr$findElement('class name', '_5rpb') #navigate to textarea element
message_textarea$clickElement()
message_textarea$sendKeysToActiveElement(list("您好，這裡是亞梭家私，此為聊天測試訊息。"))   #type text 
message_textarea$sendKeysToActiveElement(list(key="enter"))  #send text message
