library(shiny)
library(RSelenium) # R Bindings for Selenium WebDriver
remDr <- remoteDriver(browserName = "chrome") #initial public variable for Selenium chrome driver

# Define UI for dataset viewer app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("ArtsoLife Facebook Messanger Bot"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      actionButton("openbrowser", "Open Browser"),
      
      # Input: Text for providing a caption ----
      # Note: Changes made to the caption in the textInput control
      # are updated in the output area immediately as you type
      textInput(inputId = "facebook_id",
                label = "Facebook ID:",
                value = ""),
      
      textAreaInput(inputId = "message_content",
                label = "Message Content(換行可拆分訊息):",
                value = "您好，這裡是亞梭家私，此為聊天測試訊息。"),
      
      actionButton("sendtext", "Send Text")
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Verbatim text for data summary ----
      h3(textOutput("caption")),
      textOutput("status"),
      textOutput("status2"),
      textOutput("result")
      
    )
  )
)

# Define server logic to summarize and view selected dataset ----
server <- function(input, output) {
  
  output$caption <- renderText({
    "Status and Result Log"
  })
  
  observeEvent(input$openbrowser, {
    remDr$open() #open chrome browser
    url2="https://www.facebook.com/messages/t/kobebryin"   #facebook massenger url(last url is fb user's id)
    remDr$navigate(url2)
    email_textarea <- remDr$findElement('xpath', '//*[@id="email"]')   #navigate to email textarea
    email_textarea$sendKeysToElement(list("artsolife@gmail.com"))
    password_textarea <- remDr$findElement('xpath', '//*[@id="pass"]')   #navigate to password textarea
    password_textarea$sendKeysToElement(list("0927879090"))
    login_btn <- remDr$findElement('xpath', '//*[@id="loginbutton"]')   #navigate to login button
    login_btn$clickElement()
    
    #show the status and result
    remote_status2 <- "Login with artsolife@gmail.com"
    output$status2 <- renderText({ 
      remote_status2
    })
    remote_result <- "Login success"
    output$result <- renderText({ 
      remote_result
    })
  })
  
  observeEvent(input$sendtext, {
    url2=paste("https://www.facebook.com/messages/t/", input$facebook_id, sep="")   #facebook massenger url(last url is fb user's id)
    remDr$navigate(url2)
    ## write massege and send it
    message_textarea <- remDr$findElement('class name', '_5rpb') #navigate to textarea element
    message_textarea$clickElement()
    message_textarea$sendKeysToActiveElement(list(input$message_content))   #type text 
    message_textarea$sendKeysToActiveElement(list(key="enter"))  #send text message
    
    #show the status and result
    remote_status <- paste("Send to: ", input$facebook_id, sep="")
    output$status <- renderText({ 
      remote_status
    })
    remote_status2 <- paste("Message Content: ", input$message_content, sep="")
    output$status2 <- renderText({ 
      remote_status2
    })
    remote_result <- "Send massege success"
    output$result <- renderText({ 
      remote_result
    })
  })
  
}

# Create Shiny app ----
shinyApp(ui, server)

