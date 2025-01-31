﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.18408
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace TrueWheels.Web.SMSService4India {
    
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ServiceModel.ServiceContractAttribute(Namespace="http://www.webserviceX.NET", ConfigurationName="SMSService4India.SendSMSSoap")]
    public interface SendSMSSoap {
        
        [System.ServiceModel.OperationContractAttribute(Action="http://www.webserviceX.NET/SendSMSToIndia", ReplyAction="*")]
        [System.ServiceModel.XmlSerializerFormatAttribute(SupportFaults=true)]
        TrueWheels.Web.SMSService4India.SMSResult SendSMSToIndia(string MobileNumber, string FromEmailAddress, string Message);
        
        [System.ServiceModel.OperationContractAttribute(Action="http://www.webserviceX.NET/SendSMSToIndia", ReplyAction="*")]
        System.Threading.Tasks.Task<TrueWheels.Web.SMSService4India.SMSResult> SendSMSToIndiaAsync(string MobileNumber, string FromEmailAddress, string Message);
    }
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Xml", "4.0.30319.18408")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(Namespace="http://www.webserviceX.NET")]
    public partial class SMSResult : object, System.ComponentModel.INotifyPropertyChanged {
        
        private string fromEmailAddressField;
        
        private string mobileNumberField;
        
        private string providerField;
        
        private string stateField;
        
        private string statusField;
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Order=0)]
        public string FromEmailAddress {
            get {
                return this.fromEmailAddressField;
            }
            set {
                this.fromEmailAddressField = value;
                this.RaisePropertyChanged("FromEmailAddress");
            }
        }
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Order=1)]
        public string MobileNumber {
            get {
                return this.mobileNumberField;
            }
            set {
                this.mobileNumberField = value;
                this.RaisePropertyChanged("MobileNumber");
            }
        }
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Order=2)]
        public string Provider {
            get {
                return this.providerField;
            }
            set {
                this.providerField = value;
                this.RaisePropertyChanged("Provider");
            }
        }
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Order=3)]
        public string State {
            get {
                return this.stateField;
            }
            set {
                this.stateField = value;
                this.RaisePropertyChanged("State");
            }
        }
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Order=4)]
        public string Status {
            get {
                return this.statusField;
            }
            set {
                this.statusField = value;
                this.RaisePropertyChanged("Status");
            }
        }
        
        public event System.ComponentModel.PropertyChangedEventHandler PropertyChanged;
        
        protected void RaisePropertyChanged(string propertyName) {
            System.ComponentModel.PropertyChangedEventHandler propertyChanged = this.PropertyChanged;
            if ((propertyChanged != null)) {
                propertyChanged(this, new System.ComponentModel.PropertyChangedEventArgs(propertyName));
            }
        }
    }
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public interface SendSMSSoapChannel : TrueWheels.Web.SMSService4India.SendSMSSoap, System.ServiceModel.IClientChannel {
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public partial class SendSMSSoapClient : System.ServiceModel.ClientBase<TrueWheels.Web.SMSService4India.SendSMSSoap>, TrueWheels.Web.SMSService4India.SendSMSSoap {
        
        public SendSMSSoapClient() {
        }
        
        public SendSMSSoapClient(string endpointConfigurationName) : 
                base(endpointConfigurationName) {
        }
        
        public SendSMSSoapClient(string endpointConfigurationName, string remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public SendSMSSoapClient(string endpointConfigurationName, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public SendSMSSoapClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(binding, remoteAddress) {
        }
        
        public TrueWheels.Web.SMSService4India.SMSResult SendSMSToIndia(string MobileNumber, string FromEmailAddress, string Message) {
            return base.Channel.SendSMSToIndia(MobileNumber, FromEmailAddress, Message);
        }
        
        public System.Threading.Tasks.Task<TrueWheels.Web.SMSService4India.SMSResult> SendSMSToIndiaAsync(string MobileNumber, string FromEmailAddress, string Message) {
            return base.Channel.SendSMSToIndiaAsync(MobileNumber, FromEmailAddress, Message);
        }
    }
}
