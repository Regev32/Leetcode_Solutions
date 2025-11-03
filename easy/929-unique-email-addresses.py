class Solution(object):
    def numUniqueEmails(self, emails):
        """
        :type emails: List[str]
        :rtype: int
        """
        mails = set()
        for email in emails:
            local, domain = email.split('@')
            mails.add(local.replace('.', '').split('+')[0] + '@' + domain)

        return len(mails)