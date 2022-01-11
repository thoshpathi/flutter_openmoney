package com.appist.flutter_openmoney

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.open.open_web_sdk.OpenPayment
import com.open.open_web_sdk.listener.PaymentStatusListener
import com.open.open_web_sdk.model.TransactionDetails
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject
import org.json.JSONException

class OpenmoneyDelegate(private val activity: Activity) : PaymentStatusListener,
    PluginRegistry.ActivityResultListener {
    private var pendingResult: MethodChannel.Result? = null
    private var pendingReply: Map<String, Any?>? = null


    private val CODE_PAYMENT_SUCCESS = 0
    private val CODE_PAYMENT_ERROR = 1

    // Payment error codes for communicating with plugin
    private val INVALID_OPTIONS = 0
    private val PAYMENT_FAILED = 1
    private val PAYMENT_CANCELLED = 2
    private val PAYMENT_PENDING = 3
    private val UNKNOWN_ERROR = 100


    fun initPayment(options: Map<String, String>, result: MethodChannel.Result) {
        pendingResult = result

        val payEnvironment = if (options.getOrElse("paymentMode", { "SANDBOX" }) == "LIVE")
            OpenPayment.Environment.LIVE else OpenPayment.Environment.SANDBOX

        val openPayment: OpenPayment =
            OpenPayment.Builder()
                .with(activity)
                .setPaymentToken(options["paymentToken"]!!)
                .setAccessKey(options["accessKey"]!!)
                .setEnvironment(payEnvironment)
//                .setColor(colorHexCode)   // Add your Color Hex Code here
//                .setErrorColor(errorColorHexCode).  // Add your Error Color Hex Code here
//                .setLogoUrl(logoURL)  // Add your Logo URL here
                .build()

        openPayment.setPaymentStatusListener(mListener = this@OpenmoneyDelegate)
        openPayment.startPayment()
    }

    fun resync(result: MethodChannel.Result) {
        if (pendingReply != null) {
            result.success(pendingReply)
            pendingReply = null
        }
    }

    private fun sendResult(result: Map<String, Any?>) {
        pendingReply = if (pendingResult != null) {
            pendingResult?.success(result)
            null
        } else {
            result
        }
    }

    private fun resultResponse(type: Int, data: Map<String, Any?>): Map<String, Any> {
        return mapOf("type" to type, "data" to data)
    }

    private fun errorData(code: Int, message: String): Map<String, Any> {
        return mapOf("code" to code, "message" to message)
    }

    private fun paymentError(error: String?): Map<String, Any> {
        return when (error) {
            "failed" -> errorData(PAYMENT_FAILED, "Payment failed")
            "cancelled" -> errorData(PAYMENT_CANCELLED, "Payment cancelled by user")
            "pending" -> errorData(PAYMENT_PENDING, "Payment not completed yet")
            else -> errorData(UNKNOWN_ERROR, "Unknown error occured")
        }
    }

    override fun onTransactionCompleted(transactionDetails: TransactionDetails) {

        val status = transactionDetails.status
        val paymentId = transactionDetails.paymentId
        val paymentTokenId = transactionDetails.paymentTokenId

        val paymentResult = when (status) {
            "captured" -> resultResponse(
                CODE_PAYMENT_SUCCESS,
                mapOf("paymentId" to paymentId, "paymentTokenId" to paymentTokenId)
            )
            else -> resultResponse(CODE_PAYMENT_ERROR, paymentError(status))
        }
        Log.d("onTransaction", paymentResult.toString());
        sendResult(paymentResult)
    }

    override fun onError(error: String) {
        var errorMsg = "UnKnown error occured";
        try {
            val jsonObj = JSONObject(error)
            errorMsg = jsonObj.getString("message")
        }catch (e: JSONException){
            Log.e("json parse error", e.toString())
        }
        val paymentResult = resultResponse(CODE_PAYMENT_ERROR, errorData(UNKNOWN_ERROR, errorMsg))
        Log.d("onError", paymentResult.toString());
        sendResult(paymentResult)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return true
    }
}