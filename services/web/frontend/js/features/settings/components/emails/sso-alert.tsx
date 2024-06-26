import { useState } from 'react'
import { useTranslation, Trans } from 'react-i18next'
import Icon from '../../../../shared/components/icon'
import getMeta from '../../../../utils/meta'
import NotificationWrapper from '@/features/ui/components/bootstrap-5/notification-wrapper'

type InstitutionLink = {
  universityName: string
  hasEntitlement?: boolean
}

type SAMLError = {
  translatedMessage?: string
  message?: string
  tryAgain?: boolean
}

export function SSOAlert() {
  const { t } = useTranslation()

  const institutionLinked: InstitutionLink | undefined = getMeta(
    'ol-institutionLinked'
  )
  const institutionEmailNonCanonical: string | undefined = getMeta(
    'ol-institutionEmailNonCanonical'
  )
  const samlError: SAMLError | undefined = getMeta('ol-samlError')

  const [infoClosed, setInfoClosed] = useState(false)
  const [warningClosed, setWarningClosed] = useState(false)
  const [errorClosed, setErrorClosed] = useState(false)

  const handleInfoClosed = () => setInfoClosed(true)
  const handleWarningClosed = () => setWarningClosed(true)
  const handleErrorClosed = () => setErrorClosed(true)

  if (samlError) {
    return !errorClosed ? (
      <NotificationWrapper
        type="error"
        content={
          <>
            {samlError.translatedMessage
              ? samlError.translatedMessage
              : samlError.message}
            {samlError.tryAgain && <p>{t('try_again')}</p>}
          </>
        }
        isDismissible
        onDismiss={handleErrorClosed}
        bs3Props={{
          icon: (
            <Icon
              type="exclamation-triangle"
              accessibilityLabel={t('generic_something_went_wrong')}
            />
          ),
          className: 'mb-0 text-center',
        }}
      />
    ) : null
  }

  if (!institutionLinked) {
    return null
  }

  return (
    <>
      {!infoClosed && (
        <NotificationWrapper
          type="info"
          content={
            <>
              <p>
                <Trans
                  i18nKey="institution_acct_successfully_linked_2"
                  components={[<strong />]} // eslint-disable-line react/jsx-key
                  values={{ institutionName: institutionLinked.universityName }}
                  shouldUnescape
                  tOptions={{ interpolation: { escapeValue: true } }}
                />
              </p>
              {institutionLinked.hasEntitlement && (
                <p>
                  <Trans
                    i18nKey="this_grants_access_to_features_2"
                    components={[<strong />]} // eslint-disable-line react/jsx-key
                    values={{ featureType: t('professional') }}
                    shouldUnescape
                    tOptions={{ interpolation: { escapeValue: true } }}
                  />
                </p>
              )}
            </>
          }
          isDismissible
          onDismiss={handleInfoClosed}
          bs3Props={{
            className: 'mb-0 text-center',
          }}
        />
      )}
      {!warningClosed && institutionEmailNonCanonical && (
        <NotificationWrapper
          type="warning"
          content={
            <Trans
              i18nKey="in_order_to_match_institutional_metadata_2"
              components={[<strong />]} // eslint-disable-line react/jsx-key
              values={{ email: institutionEmailNonCanonical }}
              shouldUnescape
              tOptions={{ interpolation: { escapeValue: true } }}
            />
          }
          isDismissible
          onDismiss={handleWarningClosed}
          bs3Props={{
            icon: (
              <Icon
                type="exclamation-triangle"
                accessibilityLabel={t('generic_something_went_wrong')}
                fw
              />
            ),
            className: 'text-center',
          }}
        />
      )}
    </>
  )
}
