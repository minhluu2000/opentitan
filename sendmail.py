import smtplib, ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Import argparse to parse command line arguments
import argparse



def send_email(subject, body, to_email):
    # Set up email server and login credentials
    smtp_server = "smtp.gmail.com"
    smtp_port = 465
    sender_email = "minhdanhluu2000@gmail.com"
    sender_password = "jvse vesh yypx lbpi"

    # Create the email message
    message = MIMEMultipart()
    message["From"] = sender_email
    message["To"] = to_email
    message["Subject"] = subject

    # Attach the body of the email
    message.attach(MIMEText(body, "plain"))

    # Set up the SMTP connection and send the email
    with smtplib.SMTP_SSL(smtp_server, smtp_port, context=ssl.create_default_context()) as server:
        server.login(sender_email, sender_password)
        server.sendmail(sender_email, to_email, message.as_string())
        
def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Send an email")
    parser.add_argument("subject", type=str, help="The subject of the email")
    parser.add_argument("body", type=str, help="The body of the email")
    parser.add_argument("to_email", type=str, help="The recipient's email address")
    args = parser.parse_args()
    
    # if to_email is self, send to myself
    if args.to_email == "self":
        args.to_email = "minhdanhluu2000@gmail.com"

    # Send the email
    send_email(args.subject, args.body, args.to_email)
    
if __name__ == "__main__":
    main()
        

        
