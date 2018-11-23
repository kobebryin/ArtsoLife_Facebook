library(shiny)
library(DT)
library(tidyr)
library(dplyr)
library(shinyjs)
library(plan) # Trim space for check text is.empty()
library(RSelenium) # R Bindings for Selenium WebDriver

#line92 & line94 input FB username & password

#load user's data
load("userlikesFulllist.Rdata")
alluser=userlikesFulllist[,1:2]

remDr <- remoteDriver(browserName = "chrome") #initial public variable for Selenium chrome driver

# Define UI for dataset viewer app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("ArtsoLife Facebook Messenger Bot"),
  
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
      
      actionButton("sendtext", "Send Text"),
      actionButton("sendMulti_text", "Send Multi-Text"),
      hr(),
      actionButton("sendAlltext", "Send All"),
      actionButton("clearTxt", "Clear")
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Verbatim text for data summary ----
      h3(textOutput("caption")),
      textOutput("status"),
      textOutput("status2"),
      textOutput("result"),
      DT::dataTableOutput("mytable"),
      textOutput("selected")
    )
  )
)

# Define server logic to summarize and view selected dataset ----

server <- function(input, output, session) {
  ##title bar
  output$caption <- renderText({
    "Status and Result Log"
  })
  
  ##insert user's data into datatable
  output$mytable = DT::renderDataTable({
    alluser
  })
  proxy = dataTableProxy('mytable') #initial DT's variable
  
  ##function of which user's id has selected by user
  selectedRow <- eventReactive(input$mytable_rows_selected,{
    data <- alluser[input$mytable_rows_selected, ][,1]
    updateTextInput(session, "facebook_id", value = data) #change textinput's value
  })
  output$selected <- renderText({ 
    selectedRow()
    hide("selected") #hide textoutput
  })
  
  ##open browser button onClick event
  observeEvent(input$openbrowser, {
    remDr$open() #open chrome browser
    url2="https://www.facebook.com/messages/t/Artso8051"   #facebook massenger url(last url is fb user's id)
    remDr$navigate(url2)
    email_textarea <- remDr$findElement('xpath', '//*[@id="email"]')   #navigate to email textarea
    email_textarea$sendKeysToElement(list("FB_ID"))
    password_textarea <- remDr$findElement('xpath', '//*[@id="pass"]')   #navigate to password textarea
    password_textarea$sendKeysToElement(list("FB_PASSWORD"))
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
  
  ##send text button onClick event
  observeEvent(input$sendtext, {
    ## check is.empty(facebook id & message content)
    if(trim.whitespace(input$facebook_id) == "" || trim.whitespace(input$message_content) ==""){
      showNotification("Facebook ID and Message content cannot be empty.", type="error")
    }else{
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
      remote_result <- "Send message success"
      output$result <- renderText({ 
        remote_result
      })
    }
  })
  
  ##send multi-text button onClick event
  observeEvent(input$sendMulti_text, {
    ## check is.empty(facebook id & message content)
    if(trim.whitespace(input$facebook_id) == "" || trim.whitespace(input$message_content) ==""){
      showNotification("Facebook ID and Message content cannot be empty.", type="error")
    }else{
      list.usersId <- as.list(strsplit(input$facebook_id, ",")[[1]])
      for(i in list.usersId){
        url2=paste("https://www.facebook.com/messages/t/", i, sep="")   #facebook massenger url(last url is fb user's id)
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
        remote_result <- "Send message success"
        output$result <- renderText({ 
          remote_result
        })
        Sys.sleep(3)
      }
    }
  })
  
  ##send all-text button onClick event
  observeEvent(input$sendAlltext, {
    ## check is.empty(facebook id & message content)
    if(trim.whitespace(input$message_content) ==""){
      showNotification("Message content cannot be empty.", type="error")
    }else{
      list.AllusersId <- as.list(alluser[1])
      for(i in c(1:length(list.AllusersId$id))){
        url2=paste("https://www.facebook.com/messages/t/", list.AllusersId$id[i], sep="")   #facebook massenger url(last url is fb user's id)
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
        remote_result <- "Send message success"
        output$result <- renderText({ 
          remote_result
        })
        Sys.sleep(3)
      }
    }
  })
  
  ##send all-text button onClick event
  observeEvent(input$clearTxt, {
    updateTextInput(session, "facebook_id", value = "") #change textinput's value
    updateTextInput(session, "message_content", value = "") #change textinput's value
    proxy %>% selectRows(NULL)  ##reset Datatable's selected
  })
}

# Create Shiny app ----
shinyApp(ui, server)
